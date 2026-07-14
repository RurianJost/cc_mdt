replaceAdapter(
    'isPlayerInService',
    function(playerSource)
        local playerId = executeAdapter('getPlayerId', playerSource)

        return frameworkFunctions.serverSide.HasServiceByGroup(playerId, 'Police')
    end
)