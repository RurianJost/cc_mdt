local function formatTimestamp(createdAt)
    if type(createdAt) == 'number' then
        return os.date('%d/%m/%Y %H:%M:%S', createdAt)
    end

    if type(createdAt) == 'string' and createdAt ~= '' then
        return createdAt
    end

    return LANGUAGE.COMMON_DATE_EMPTY
end

local function addInventoryMissionMdtPrison(playerSourceOrId)
    if not playerSourceOrId or GetResourceState('fta-inventory') ~= 'started' then
        return
    end

    pcall(function()
        exports['fta-inventory']:AddMissionProgress(playerSourceOrId, 'mdt_prison', 1, { autoClaim = true })
        exports['fta-inventory']:AddMissionXp(playerSourceOrId, 50, {
            scope = 'personal',
            notify = true,
            label = 'MDT'
        })
    end)
end

local function getPlayerOcurrencesData(playerid)
    local occurrencesEntries = {}
    local serverOccurences = Ocurrences:Get()
    local latestOccurrenceId = nil
    local latestAvatarURL = ''

    for occurrenceId, occurrenceData in pairs(serverOccurences) do
        if tostring(occurrenceData.suspectId) == tostring(playerid) then
            local officerId = occurrenceData.officerId
            local officerName = executeAdapter('getPlayerName', officerId)

            local occurrenceFine = (occurrenceData.payload and occurrenceData.payload.fine) or 0
            local occurrenceStatus = occurrenceData.isFinished and LANGUAGE.OCCURRENCE_STATUS_SERVED or LANGUAGE.OCCURRENCE_STATUS_PENDING
            local occurrenceTitle = LANGUAGE.OCCURRENCE_TITLE_PREFIX:format(tostring(occurrenceId))
            local occurrenceCreatedAt = formatTimestamp(occurrenceData.createdAt)

            table.insert(occurrencesEntries, {
                occurrenceId,
                occurrenceTitle,
                occurrenceCreatedAt,
                officerName,
                officerId,
                occurrenceFine,
                occurrenceStatus
            })

            if latestOccurrenceId == nil or occurrenceId > latestOccurrenceId then
                latestOccurrenceId = occurrenceId
                latestAvatarURL = (type(occurrenceData.photoURL) == 'string' and occurrenceData.photoURL) or ''
            end
        end
    end

    table.sort(occurrencesEntries, function(a, b)
        return tonumber(a[1]) > tonumber(b[1])
    end)

    return occurrencesEntries, latestAvatarURL
end

local function getVehicleFinesData(vehiclePlate)
    local vehicleFinesEntries = {}
    local fineRecords = FineRecord:GetByVehiclePlate(vehiclePlate)

    for fineRecordId, fineRecordData in pairs(fineRecords) do
        local officerId = fineRecordData.officerId
        local officerName = executeAdapter('getPlayerName', officerId)
        local createdAt = fineRecordData.createdAt

        if type(createdAt) == 'number' then
            createdAt = os.date('%d/%m/%Y %H:%M:%S', createdAt)
        elseif type(createdAt) ~= 'string' or createdAt == '' then
            createdAt = LANGUAGE.COMMON_DATE_EMPTY
        end

        table.insert(vehicleFinesEntries, {
            fineRecordId,
            fineRecordData.description,
            createdAt,
            officerName,
            officerId,
            fineRecordData.value or 0,
            LANGUAGE.FINE_RECORD_STATUS_PENDING
        })
    end

    table.sort(vehicleFinesEntries, function(a, b)
        return tonumber(a[1]) > tonumber(b[1])
    end)

    return vehicleFinesEntries
end

function api.applyVehicleFine(vehiclePlate, fines)
    if not __isAuth__ then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    if type(vehiclePlate) ~= 'string' or vehiclePlate == '' or type(fines) ~= 'table' then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local vehicleOwnerId = executeAdapter('getVehicleOwnerFromPlate', vehiclePlate)

    if not vehicleOwnerId then
        return false, LANGUAGE.VEHICLE_NOT_FOUND
    end

    local officerId = executeAdapter('getPlayerId', playerSource)

    if not officerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local normalizedPlate = tostring(vehiclePlate):upper():gsub('%s+', ''):gsub('%-', '')
    local fineEntries = {}

    for _, fineId in ipairs(fines) do
        local normalizedFineId = tonumber(fineId)
        local fineData = normalizedFineId and LEGISLATION_CONFIG.TRAFFIC_TICKETS[normalizedFineId]

        if fineData then
            local fineValue = tonumber(fineData.FINE) or 0
            local fineDescription = ('%s - $%s'):format(fineData.NAME, fineValue)

            fineEntries[#fineEntries + 1] = {
                fineId = normalizedFineId,
                description = fineDescription,
                value = fineValue
            }
        end
    end

    if #fineEntries == 0 then
        return false, LANGUAGE.VEHICLE_FINE_INVALID
    end

    local recordStatus, recordResult = FineRecord:CreateMany('VEHICLE', normalizedPlate, fineEntries, officerId)

    if not recordStatus then
        return false, recordResult
    end

    for _, fineEntry in ipairs(fineEntries) do
        local applied = executeAdapter('givePlayerFine', vehicleOwnerId, fineEntry.value, officerId, fineEntry.description)

        if not applied then
            for _, recordId in ipairs(recordResult or {}) do
                FineRecord:Delete(recordId)
            end

            return false, LANGUAGE.VEHICLE_FINE_APPLY_ERROR
        end
    end

    return true
end

function api.getOccurrenceFromSearch(search)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local isValidPlate = executeAdapter('isValidVehiclePlate', search)

    if isValidPlate then
        local vehiclePlate = search:upper()
        local ownerId = executeAdapter('getVehicleOwnerFromPlate', vehiclePlate)

        if not ownerId then
            return 'NOT_FOUND', {}
        end

        local ownerName = executeAdapter('getPlayerName', ownerId)

        local vehicleModel = executeAdapter('getVehicleModelFromPlate', vehiclePlate)
        local isVehicleDetained = executeAdapter('isVehicleDetained', vehiclePlate, vehicleModel, ownerId)
        local formattedVehicleModel = vehicleModel or LANGUAGE.COMMON_UNDEFINED
        local vehicleImageURL = ''

        if vehicleModel and type(GENERAL_CONFIG.VEHICLES_URL) == 'string' and GENERAL_CONFIG.VEHICLES_URL ~= '' then
            vehicleImageURL = GENERAL_CONFIG.VEHICLES_URL:format(tostring(vehicleModel))
        end

        local resultEntries = {
            search,
            formattedVehicleModel,
            isVehicleDetained,
            vehicleImageURL,
            ownerId,
            ownerName
        }

        local vehicleFines = getVehicleFinesData(vehiclePlate)

        return 'VEHICLE', resultEntries, vehicleFines
    else
        local targetId = executeAdapter('getPlayerIdByIdentifier', search)

        if not targetId then
            return 'NOT_FOUND', {}
        end

        local targetAge = executeAdapter('getPlayerAge', targetId)
        local targetName = executeAdapter('getPlayerName', targetId)
        local targetRegistration = executeAdapter('getPlayerRegistration', targetId)
        local targetFineValue = executeAdapter('getPlayerFineValue', targetId)
        local occurrencesEntries, targetAvatarURL = getPlayerOcurrencesData(targetId)

        local targetEntries = {
            targetId,
            targetName,
            targetAvatarURL,
            targetAge,
            targetRegistration,
            targetFineValue
        }

        return 'USER', targetEntries, occurrencesEntries
    end
end

function api.registerNewOccurrence(suspectId, suspectDescription, crimes, attenuants, aggravants, photo)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    if not suspectId then
        return false, LANGUAGE.ERROR_SUSPECT_DATA_INVALID
    end

    if not crimes or #crimes == 0 then
        return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
    end

    local officerId = executeAdapter('getPlayerId', playerSource)
    local status, errorMessage = Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photo)

    return status, (not status and errorMessage)
end

function api.updateRegister(ocurrenceId, suspectId, crimes)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    if not ocurrenceId then
        return false, LANGUAGE.ERROR_OCCURRENCE_ID_NOT_INFORMED
    end

    if not suspectId then
        return false, LANGUAGE.ERROR_SUSPECT_ID_NOT_INFORMED
    end

    local success, result = Ocurrences:Update(ocurrenceId, suspectId, crimes)

    if not success then
        return false, result
    end

    return true, {
        result.id,
        result.suspectId,
        result.suspectDescription,
        result.isFinished,
        result.payload.sentence,
        result.payload.fine,
        result.payload.bail,
        result.crimes
    }
end

function api.deleteRegister(ocurrenceId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end
    
    local canDelete = executeAdapter('canDeleteRegister', playerSource, policeOrganization)

    if not canDelete then
        return
    end

    local status, errorMessage = Ocurrences:Delete(ocurrenceId)

    return status, errorMessage
end

function api.finishRegister(ocurrenceId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local occurrence = Ocurrences:Get(ocurrenceId)

    if not occurrence then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
    end

    if occurrence.isFinished then
        return true, LANGUAGE.PRISON_FINISH_SUCCESS
    end

    local suspectId = occurrence.suspectId
    local prisonSentence = tonumber(occurrence.payload and occurrence.payload.sentence) or 0
    local suspectSource = executeAdapter('getSourceFromPlayerId', suspectId)
    local officerId = executeAdapter('getPlayerId', playerSource)

    local updated = executeAdapter('updateOcurrenceFinished', ocurrenceId, true)

    if not updated then
        return false, LANGUAGE.ERROR_OCCURRENCE_UPDATE_DB
    end

    local status, errorMessage = Prison:Create(suspectId, ocurrenceId, prisonSentence, officerId, suspectSource)

    if not status then
        executeAdapter('updateOcurrenceFinished', ocurrenceId, false)

        return false, errorMessage
    end

    occurrence.isFinished = true
    addInventoryMissionMdtPrison(playerSource)
    
    if suspectSource then
        return true, LANGUAGE.PRISON_FINISH_SUCCESS
    end

    return true, LANGUAGE.PRISON_FINISH_SUCCESS_OFFLINE
end

function api.getServerRegisters()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    local formattedRegisters = {}
    local serverOccurences = Ocurrences:Get()

    for ocurrenceId, ocurrenceData in pairs(serverOccurences) do
        local officerId = ocurrenceData.officerId
        local officerName = executeAdapter('getPlayerName', officerId)

        local suspectId = ocurrenceData.suspectId
        local suspectName = executeAdapter('getPlayerName', suspectId)
        local suspectIdentity = executeAdapter('getPlayerRegistration', suspectId)

        local formattedDate = formatTimestamp(ocurrenceData.createdAt)

        table.insert(formattedRegisters, {
            ocurrenceId,
            officerId,
            officerName,
            suspectId,
            suspectName,
            suspectIdentity,
            ocurrenceData.crimes,
            ocurrenceData.suspectDescription,
            ocurrenceData.payload.sentence,
            ocurrenceData.payload.fine,
            ocurrenceData.payload.bail,
            formattedDate,
            ocurrenceData.isFinished
        })
    end

    return formattedRegisters
end
