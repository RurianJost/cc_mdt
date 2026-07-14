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

    Interface:OnPlayerOpen(playerSource)
end

function api.playerClosedInterface()
    if not __isAuth__ then
        return
    end

    local playerSource = source

    Interface:OnPlayerClose(playerSource)
end

function api.getPlayerData()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local policeRanking = executeAdapter('getPlayerPoliceRanking', playerSource)    
    local inService = executeAdapter('isPlayerInService', playerSource)
    
    return {
        playerId,
        playerName,
        policeRanking,
        inService
    }
end