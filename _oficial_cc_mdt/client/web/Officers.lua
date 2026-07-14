RegisterNUICallback('deleteOfficer', function(data, callback)
    local status, errorMessage = apiServer.deleteOfficer(data.officerId)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('getOfficers', function(data, callback)
    local formattedOfficers = {}
    local officersEntries = apiServer.getServerOfficers()

    for index, entries in ipairs(officersEntries) do
        local playerId, playerName, policeRank, inService, playerCoords = table.unpack(entries)

        formattedOfficers[index] = {
            id = tostring(playerId),
            name = playerName, 
            avatarURL = nil,
            policeRank = policeRank,
            inService = inService, 
            coords = {
                x = playerCoords[1],
                y = playerCoords[2],
                z = playerCoords[3]
            }
        }
    end

    callback(formattedOfficers)
end)

RegisterNUICallback('getOfficersOnMap', function(data, callback)
    local formattedOfficersCoords = {}
    local officersCoordsEntries = apiServer.getOfficersCoordinates()

    for index, entries in ipairs(officersCoordsEntries) do
        local playerId, playerName, playerCoords = table.unpack(entries)

        formattedOfficersCoords[index] = {
            id = playerId, 
            name = playerName, 
            coords = playerCoords
        }
    end

    callback(formattedOfficersCoords)
end)

function updateOfficersOnMap(officersCoordsEntries)
    local formattedOfficersCoords = {}

    for index, entries in ipairs(officersCoordsEntries) do
        local playerId, playerName, playerCoords = table.unpack(entries)

        formattedOfficersCoords[index] = {
            id = playerId, 
            name = playerName, 
            coords = playerCoords
        }
    end

    SendNUIMessage({
        action = "updateOfficersOnMap",
        data = formattedOfficersCoords
    })
end