_G.Interface = {
    cache = {}
}

local function getPlayerCoordsBySource(playerSource)
    if not playerSource then
        return { 0, 0, 0 }
    end

    local officerPed = GetPlayerPed(playerSource)

    if not officerPed or officerPed <= 0 or not DoesEntityExist(officerPed) then
        return { 0, 0, 0 }
    end

    local officerCoordinates = GetEntityCoords(officerPed)

    if not officerCoordinates then
        return { 0, 0, 0 }
    end

    local x = tonumber(officerCoordinates.x)
    local y = tonumber(officerCoordinates.y)
    local z = tonumber(officerCoordinates.z)

    if not x or not y or not z then
        return { 0, 0, 0 }
    end

    return { x, y, z }
end

function Interface:OnPlayerOpen(playerSource)
    if self.cache[playerSource] then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return
    end

    local playerName = executeAdapter('getPlayerName', playerId)

    self.cache[playerSource] = { 
        id = playerId, 
        name = playerName 
    }
end

function Interface:OnPlayerClose(playerSource)
    self.cache[playerSource] = nil
end

function Interface:IsPlayerInterfaceOpen(searchSource)
    return not not self.cache[searchSource]
end

function Interface:GetAllOpenInterfaces()
    return self.cache
end

function Interface:OnResourceStart()
    Citizen.CreateThread(function()
        while true do
            if __isAuth__ then
                local formattedEntries = {}
                local onlinePolicesInService = executeAdapter('getOnlinePolicesInService')

                for _, player in ipairs(onlinePolicesInService) do
                    local playerCoords = getPlayerCoordsBySource(player.source)
                    local playerName = self.cache[player.source] and self.cache[player.source].name or executeAdapter('getPlayerName', player.id)
                    local ORG_CONFIG = ORGANIZATIONS_CONFIG[player.organization] or { MAP_COLOR = '#0000ff' }

                    formattedEntries[#formattedEntries + 1] = { player.id, playerName, playerCoords, ORG_CONFIG.MAP_COLOR }
                end

                for playerSource in pairs(self.cache) do
                    TriggerClientEvent('cc_mdt:updateOfficersOnMap', playerSource, formattedEntries)
                end
            end

            Citizen.Wait(GENERAL_CONFIG.TIME_TO_UPDATE_OFFICERS_MAP)
        end
    end)
end
