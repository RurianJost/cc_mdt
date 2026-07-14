_G.Ocurrences = {
    cache = {}
}

function Ocurrences:Setup()
    self.cache = executeAdapter('getDatabaseOcurrences')
end

local function calculateOcurrencePayload(crimes, attenuants, aggravants)
    local totalFine = 0
    local totalBail = 0
    local totalSentence = 0
    local isBailable = true

    for _, crimeId in ipairs(crimes) do
        local crime = LEGISLATION_CONFIG.PENAL_CODES[crimeId]
        
        if crime then
            totalFine = totalFine + crime.FINE
            totalSentence = totalSentence + crime.SENTENCE

            if crime.BAIL == false then
                isBailable = false
            else
                totalBail = totalBail + crime.BAIL
            end
        end
    end

    local aggravantPercentage = 0

    for _, aggravantId in ipairs(aggravants) do
        local factor = LEGISLATION_CONFIG.AGGRAVATING_FACTORS[aggravantId]
       
        if factor then
            aggravantPercentage = aggravantPercentage + factor.PERCENTAGE
        end
    end

    local attenuantPercentage = 0

    for _, attenuantId in ipairs(attenuants) do
        local factor = LEGISLATION_CONFIG.ATTENUANTS_FACTORS[attenuantId]

        if factor then
            attenuantPercentage = attenuantPercentage + factor.PERCENTAGE
        end
    end

    local netPercentage = aggravantPercentage - attenuantPercentage
    local multiplier = 1 + (netPercentage / 100)

    totalSentence = math.max(1, math.floor(totalSentence * multiplier))
    totalFine = math.max(0, math.floor(totalFine * multiplier))
    totalBail = isBailable and math.max(0, math.floor(totalBail * multiplier)) or false

    return {
        fine = totalFine,
        bail = totalBail,
        isBailable = isBailable, 
        sentence = totalSentence
    }
end

function Ocurrences:GetLastId(officerId, suspectId, suspectDescription)
    local row = executeAdapter('executeSync',
        'SELECT id FROM cc_mdt_ocurrences WHERE officer_id = ? AND suspect_id = ? AND suspect_description = ? ORDER BY id DESC LIMIT 1',
        { officerId, suspectId, suspectDescription }
    )

    if not row or not row[1] then
        return nil
    end

    return row[1].id
end

function Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL)
    if not suspectId or not crimes then
        return false, 'Parâmetros obrigatórios ausentes.'
    end

    local penaltyPayload = calculateOcurrencePayload(crimes, attenuants, aggravants)
    local consultResult = executeAdapter(
        'executeSync',
        'INSERT INTO cc_mdt_ocurrences (officer_id, suspect_id, suspect_description, crimes, attenuants, aggravants, photo_url, payload, is_finished) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            officerId,
            suspectId,
            suspectDescription or 'Não fornecida',
            json.encode(crimes),
            json.encode(attenuants or {}),
            json.encode(aggravants or {}),
            photoURL or nil,
            json.encode(penaltyPayload),
            0 -- is_finished
        }
    )

    if not consultResult then 
        return false, 'Erro no DB.' 
    end

    local ocurrenceId = consultResult.insertId or self:GetLastId(officerId, suspectId)

    if not ocurrenceId then
        return false, 'Erro ao recuperar ID da ocorrência criada.'
    end

    self.cache[ocurrenceId] = {
        id                 = ocurrenceId,
        officerId          = officerId,
        suspectId          = suspectId,
        suspectDescription = suspectDescription,
        crimes             = crimes,
        attenuants         = attenuants or {},
        aggravants         = aggravants or {},
        photoURL           = photoURL,
        payload            = penaltyPayload,
        isFinished         = false,
        createdAt          = os.time()
    }

    return true, ocurrenceId
end

function Ocurrences:Update(ocurrenceId, newSuspectId, newCrimes)
    local cached = self:Get(ocurrenceId)

    if not cached then
        return false, 'Ocorrência não encontrada.'
    end

    local params = {}
    local updates = {}
    local setClauses = {}

    if newSuspectId and newSuspectId ~= cached.suspectId then
        setClauses[#setClauses + 1] = 'suspect_id = ?'
        params[#params + 1] = newSuspectId
        updates.suspectId = newSuspectId
    end

    local crimesChanged = false

    if newCrimes then
        if #newCrimes ~= #cached.crimes then
            crimesChanged = true
        else
            for i, id in ipairs(newCrimes) do
                if cached.crimes[i] ~= id then
                    crimesChanged = true

                    break
                end
            end
        end
    end

    if crimesChanged then
        local newPayload = calculateOcurrencePayload(newCrimes, cached.attenuants, cached.aggravants)

        setClauses[#setClauses + 1] = 'crimes = ?'
        params[#params + 1] = json.encode(newCrimes)

        setClauses[#setClauses + 1] = 'payload = ?'
        params[#params + 1] = json.encode(newPayload)

        updates.crimes  = newCrimes
        updates.payload = newPayload
    end

    if #setClauses == 0 then
        return false, 'Nenhuma alteração detectada.'
    end

    params[#params + 1] = ocurrenceId

    local success = executeAdapter('executeSync',
        'UPDATE cc_mdt_ocurrences SET ' .. table.concat(setClauses, ', ') .. ' WHERE id = ?',
        params
    )

    if not success then
        return false, 'Erro ao atualizar ocorrência no banco de dados.'
    end

    for key, value in pairs(updates) do
        cached[key] = value
    end

    return true, cached
end

function Ocurrences:Delete(ocurrenceId)
    if not ocurrenceId or not self.cache[ocurrenceId] then
        return false, 'Ocorrência não encontrada.'
    end

    local success = executeAdapter('executeSync', 'DELETE FROM cc_mdt_ocurrences WHERE id = ?', { ocurrenceId })

    if not success then
        return false, 'Erro ao deletar ocorrência do banco de dados.'
    end

    self.cache[ocurrenceId] = nil

    return true
end

function Ocurrences:Get(ocurrenceId)
    if ocurrenceId then
        return self.cache[ocurrenceId]
    end

    return self.cache
end