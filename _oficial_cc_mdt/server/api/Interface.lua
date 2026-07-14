function api.canOpenPainel()
    if not __isAuth__ then
        return
    end

    local playerSource = source

    return executeAdapter('canOpenPainel', playerSource)
end

function api.playerOpenInterface()
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    Interface:OnPlayerOpen(playerSource)
end

function api.playerClosedInterface()
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    Interface:OnPlayerClose(playerSource)
end

function api.updateAvatarURL(avatarURL)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)
    
    if playerId then
        ProfilePhotos:SetPhoto(playerId, avatarURL)
        
        local playerName = executeAdapter('getPlayerName', playerId)
        local policeRanking = executeAdapter('getPlayerPoliceRanking', playerId)    
        local inService = executeAdapter('isPlayerInService', playerSource)
        local canManageOfficers = executeAdapter('canManageOfficers', playerSource, policeOrganization)

        TriggerClientEvent('cc_mdt:updateUserData', playerSource, playerId, playerName, policeRanking, inService, avatarURL, canManageOfficers)
    end
end

function api.getPlayerData()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local policeRanking = executeAdapter('getPlayerPoliceRanking', playerId)    
    local inService = executeAdapter('isPlayerInService', playerSource)
    local avatarURL = ProfilePhotos:GetPhoto(playerId)
    local canManageOfficers = executeAdapter('canManageOfficers', playerSource, policeOrganization)

    return {
        playerId,
        playerName,
        policeRanking,
        inService, 
        avatarURL, 
        canManageOfficers
    }
end

function api.startPrisonTask(taskIndex)
    if not __isAuth__ then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    return Prison:StartTask(playerSource, playerId, taskIndex)
end

function api.reducePrisonSentence(taskIndex)
    if not __isAuth__ then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local success, sentence, releaseTick = Prison:CompleteTask(playerSource, playerId, taskIndex)

    if not success then
        return false, sentence
    end

    return true, sentence, releaseTick
end
