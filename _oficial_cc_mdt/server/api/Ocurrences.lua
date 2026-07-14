local function isPlate(search)
    return false
end

function api.getOccurrenceFromSearch(search)
    if not __isAuth__ then
        return 
    end

    local playerSource = source

    if isPlate(search) then
        local resultEntries = {}

        return 'VEHICLE', resultEntries
    else
        local targetId = executeAdapter('getPlayerIdByIdentifier', search)

        if not targetId then
            return 'NOT_FOUND', {}
        end

        local targetAge = executeAdapter('getPlayerAge', targetId)
        local targetName = executeAdapter('getPlayerName', targetId)
        local targetRegistration = executeAdapter('getPlayerRegistration', targetId)
        local targetFineValue = executeAdapter('getPlayerFineValue', targetId)
        local targetAvatarURL = '' -- Opcional
        local targetStatus = '?'

        local targetEntries = {
            targetId, 
            targetName, 
            targetAvatarURL, 
            targetAge, 
            targetRegistration, 
            targetFineValue, 
            targetStatus
        }

        local occurrencesEntries = {}

        return 'USER', { targetEntries, occurrencesEntries }
    end
end

function api.registerNewOccurrence(suspectId, suspectDescription, crimes, attenuants, aggravants, photo)
    if not __isAuth__ then
        return
    end

    local playerSource = source

    if not suspectId then
        return false, 'Dados do suspeito inválidos ou ausentes.'
    end

    if not crimes or #crimes == 0 then
        return false, 'Nenhum crime informado.'
    end

    local officerId = executeAdapter('getPlayerId', playerSource)
    local status, errorMessage = Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photo)

    return status, (not status and errorMessage)
end

function api.updateRegister(ocurrenceId, suspectId, crimes)
    if not __isAuth__ then
        return
    end

    if not ocurrenceId then
        return false, 'ID da ocorrência não informado.'
    end

    if not suspectId then
        return false, 'ID do suspeito não informado.'
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

    local status, errorMessage = Ocurrences:Delete(ocurrenceId)

    return status, errorMessage
end

function api.finishRegister(ocurrenceId)
    if not __isAuth__ then
        return 
    end

    -- Prender jogador
end

function api.getServerRegisters()
    if not __isAuth__ then
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

        local formattedDate = os.date('%d/%m/%Y %H:%M:%S', ocurrenceData.createdAt)

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