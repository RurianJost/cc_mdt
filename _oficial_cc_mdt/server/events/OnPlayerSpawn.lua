local LastPlayerSpawnAt = {}

RegisterNetEvent('cc_mdt:onPlayerSpawn', function()
    local playerSource = source
    local currentTime = os.time()

    if LastPlayerSpawnAt[playerSource] and (currentTime - LastPlayerSpawnAt[playerSource]) < 5 then
        return
    end

    LastPlayerSpawnAt[playerSource] = currentTime

    local timeoutAt = GetGameTimer() + 30000

    while not __isAuth__ and GetGameTimer() < timeoutAt do
        Citizen.Wait(1000)
    end

    if not __isAuth__ then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)

    while not playerId and GetGameTimer() < timeoutAt do
        if GetPlayerPing(playerSource) <= 0 then
            return
        end

        playerId = executeAdapter('getPlayerId', playerSource)

        Citizen.Wait(1000)
    end

    if not playerId then
        return
    end

    Prison:OnPlayerSpawn(playerSource, playerId)
end)
