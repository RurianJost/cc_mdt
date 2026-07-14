RegisterNetEvent('RKG_Store:onPlayerSpawn', function()
    local playerSource = source

    while not __isAuth__ do
        Citizen.Wait(1000)
    end

    local playerId = executeAdapter('getPlayerId', playerSource)

    while not playerId do
        playerId = executeAdapter('getPlayerId', playerSource)

        Citizen.Wait(1000)
    end

    
end)