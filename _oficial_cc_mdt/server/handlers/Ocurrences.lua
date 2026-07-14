_G.Ocurrences = {
    cache = {}
}

function Ocurrences:OnResourceStart()
    self.cache = executeAdapter('getDatabaseOcurrences')
end

local function normalizeIdList(values, allowedValues)
    local normalized = {}
    local added = {}

    if type(values) ~= 'table' then
        return normalized
    end

    for _, value in ipairs(values) do
        local id = tonumber(value)

        if id and allowedValues[id] and not added[id] then
            normalized[#normalized + 1] = id
            added[id] = true
        end
    end

    return normalized
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

function Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL)
    if not suspectId or not crimes then
        return false, LANGUAGE.ERROR_REQUIRED_PARAMS
    end

    crimes = normalizeIdList(crimes, LEGISLATION_CONFIG.PENAL_CODES)
    attenuants = normalizeIdList(attenuants, LEGISLATION_CONFIG.ATTENUANTS_FACTORS)
    aggravants = normalizeIdList(aggravants, LEGISLATION_CONFIG.AGGRAVATING_FACTORS)

    if #crimes == 0 then
        return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
    end

    local penaltyPayload = calculateOcurrencePayload(crimes, attenuants, aggravants)
    local ocurrenceId = executeAdapter('createOcurrence', officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL, penaltyPayload)

    if not ocurrenceId then
        return false, LANGUAGE.ERROR_OCCURRENCE_CREATED_ID
    end

    self.cache[ocurrenceId] = {
        id = ocurrenceId,
        officerId = officerId,
        suspectId = suspectId,
        suspectDescription = suspectDescription,
        crimes = crimes,
        attenuants = attenuants or {},
        aggravants = aggravants or {},
        photoURL = photoURL,
        payload = penaltyPayload,
        isFinished = false,
        createdAt = os.time()
    }

    return true, ocurrenceId
end

function Ocurrences:Update(ocurrenceId, newSuspectId, newCrimes)
    local cached = self:Get(ocurrenceId)

    if not cached then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
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
        newCrimes = normalizeIdList(newCrimes, LEGISLATION_CONFIG.PENAL_CODES)

        if #newCrimes == 0 then
            return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
        end

        cached.crimes = cached.crimes or {}

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

        updates.crimes = newCrimes
        updates.payload = newPayload
    end

    if #setClauses == 0 then
        return false, LANGUAGE.ERROR_NO_CHANGES_DETECTED
    end

    local success = executeAdapter('updateOcurrence', ocurrenceId, setClauses, params)

    if not success then
        return false, LANGUAGE.ERROR_OCCURRENCE_UPDATE_DB
    end

    for key, value in pairs(updates) do
        cached[key] = value
    end

    return true, cached
end

function Ocurrences:Delete(ocurrenceId)
    if not ocurrenceId or not self.cache[ocurrenceId] then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
    end

    local success = executeAdapter('deleteOcurrence', ocurrenceId)

    if not success then
        return false, LANGUAGE.ERROR_OCCURRENCE_DELETE_DB
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
