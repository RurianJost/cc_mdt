_G.FineRecord = {
    cache = {}
}

local VALID_FINE_RECORD_TYPES = {
    USER = true,
    VEHICLE = true
}

local function normalizeFineRecordType(recordType)
    local normalizedType = tostring(recordType or ''):upper()

    if VALID_FINE_RECORD_TYPES[normalizedType] then
        return normalizedType
    end
end

local function normalizeFineRecordTarget(targetIdentifier)
    if targetIdentifier == nil then
        return
    end

    local normalizedTarget = tostring(targetIdentifier)

    if normalizedTarget == '' then
        return
    end

    return normalizedTarget
end

local function normalizeFineRecordValue(fineValue)
    local parsedValue = math.floor(tonumber(fineValue) or 0)

    if parsedValue < 0 then
        return 0
    end

    return parsedValue
end

function FineRecord:OnResourceStart()
    self.cache = executeAdapter('getDatabaseFineRecords')
end

function FineRecord:Get(recordId)
    if recordId then
        return self.cache[recordId]
    end

    return self.cache
end

function FineRecord:GetByPlayerId(playerId)
    local targetPlayerId = normalizeFineRecordTarget(playerId)
    local formattedRecords = {}

    if not targetPlayerId then
        return formattedRecords
    end

    for recordId, recordData in pairs(self.cache) do
        if recordData.type == 'USER' and tostring(recordData.targetIdentifier) == targetPlayerId then
            formattedRecords[recordId] = recordData
        end
    end

    return formattedRecords
end

function FineRecord:GetByVehiclePlate(vehiclePlate)
    local targetVehiclePlate = normalizeFineRecordTarget(vehiclePlate)
    local formattedRecords = {}

    if not targetVehiclePlate then
        return formattedRecords
    end

    targetVehiclePlate = targetVehiclePlate:upper():gsub('%s+', ''):gsub('%-', '')

    for recordId, recordData in pairs(self.cache) do
        if recordData.type == 'VEHICLE' then
            local recordPlate = tostring(recordData.targetIdentifier):upper():gsub('%s+', ''):gsub('%-', '')

            if recordPlate == targetVehiclePlate then
                formattedRecords[recordId] = recordData
            end
        end
    end

    return formattedRecords
end

function FineRecord:Create(recordType, targetIdentifier, fineId, description, fineValue, officerId)
    local normalizedType = normalizeFineRecordType(recordType)

    if not normalizedType then
        return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
    end

    local normalizedTarget = normalizeFineRecordTarget(targetIdentifier)

    if not normalizedTarget then
        return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
    end

    if not fineId then
        return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
    end

    local createdRecordId = executeAdapter(
        'createFineRecord',
        normalizedType,
        normalizedTarget,
        fineId,
        description,
        fineValue,
        officerId
    )

    if not createdRecordId then
        return false, LANGUAGE.FINE_RECORD_CAN_NOT_CREATED_ID
    end

    self.cache[createdRecordId] = {
        id = createdRecordId,
        type = normalizedType,
        targetIdentifier = normalizedTarget,
        fineId = tonumber(fineId) or fineId,
        description = tostring(description or ''),
        value = normalizeFineRecordValue(fineValue),
        officerId = tostring(officerId or ''),
        createdAt = os.time()
    }

    return true, createdRecordId
end

function FineRecord:CreateMany(recordType, targetIdentifier, fineEntries, officerId)
    local normalizedType = normalizeFineRecordType(recordType)

    if not normalizedType then
        return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
    end

    local normalizedTarget = normalizeFineRecordTarget(targetIdentifier)

    if not normalizedTarget then
        return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
    end

    if type(fineEntries) ~= 'table' or #fineEntries == 0 then
        return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
    end

    local recordsToInsert = {}
    local createdIds = {}
    local nextTemporaryId = 0

    for _, fineEntry in ipairs(fineEntries) do
        if fineEntry and fineEntry.fineId then
            recordsToInsert[#recordsToInsert + 1] = {
                fineId = tonumber(fineEntry.fineId) or fineEntry.fineId,
                description = tostring(fineEntry.description or ''),
                value = normalizeFineRecordValue(fineEntry.value),
                officerId = tostring(officerId or '')
            }
        end
    end

    if #recordsToInsert == 0 then
        return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
    end

    local firstInsertId = executeAdapter('createFineRecords', normalizedType, normalizedTarget, recordsToInsert, officerId)

    if not firstInsertId then
        return false, LANGUAGE.FINE_RECORD_CAN_NOT_CREATED_ID
    end

    for i, recordData in ipairs(recordsToInsert) do
        local recordId = firstInsertId + (i - 1)

        self.cache[recordId] = {
            id = recordId,
            type = normalizedType,
            targetIdentifier = normalizedTarget,
            fineId = recordData.fineId,
            description = recordData.description,
            value = recordData.value,
            officerId = recordData.officerId,
            createdAt = os.time()
        }

        createdIds[#createdIds + 1] = recordId
    end

    return true, createdIds
end

function FineRecord:Update(recordId, recordType, targetIdentifier, fineId, description, fineValue, officerId)
    local cachedRecord = self:Get(recordId)

    if not cachedRecord then
        return false, LANGUAGE.FINE_RECORD_NOT_FOUND
    end

    local normalizedType = normalizeFineRecordType(recordType or cachedRecord.type)

    if not normalizedType then
        return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
    end

    local normalizedTarget = normalizeFineRecordTarget(targetIdentifier or cachedRecord.targetIdentifier)

    if not normalizedTarget then
        return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
    end

    local nextFineId = fineId or cachedRecord.fineId

    if not nextFineId then
        return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
    end

    local updatedRecord = {
        type = normalizedType,
        targetIdentifier = normalizedTarget,
        fineId = tonumber(nextFineId) or nextFineId,
        description = tostring(description ~= nil and description or cachedRecord.description or ''),
        value = normalizeFineRecordValue(fineValue ~= nil and fineValue or cachedRecord.value),
        officerId = tostring(officerId ~= nil and officerId or cachedRecord.officerId or '')
    }

    executeAdapter(
        'updateFineRecord',
        recordId,
        updatedRecord.type,
        updatedRecord.targetIdentifier,
        updatedRecord.fineId,
        updatedRecord.description,
        updatedRecord.value,
        updatedRecord.officerId
    )

    cachedRecord.type = updatedRecord.type
    cachedRecord.targetIdentifier = updatedRecord.targetIdentifier
    cachedRecord.fineId = updatedRecord.fineId
    cachedRecord.description = updatedRecord.description
    cachedRecord.value = updatedRecord.value
    cachedRecord.officerId = updatedRecord.officerId

    return true, cachedRecord
end

function FineRecord:Delete(recordId)
    if not self.cache[recordId] then
        return false, LANGUAGE.FINE_RECORD_NOT_FOUND
    end

    executeAdapter('deleteFineRecord', recordId)
    self.cache[recordId] = nil

    return true
end
