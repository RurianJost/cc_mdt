RegisterNUICallback('deleteOfficer', function(data, callback)
    local status, errorMessage = apiServer.fireOfficer(data.officerId)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('promoteOfficer', function(data, callback)
    local status, errorMessage = apiServer.promoteOfficer(data.officerId)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('demoteOfficer', function(data, callback)
    local status, errorMessage = apiServer.demoteOfficer(data.officerId)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('hireOfficer', function(data, callback)
    local status, errorMessage = apiServer.hireOfficer(data.officerId)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('getOfficers', function(data, callback)
    local formattedOfficers = {}
    local officersEntries = apiServer.getServerOfficers()

    for index, entries in ipairs(officersEntries) do
        local playerId, playerName, policeRank, inService, playerCoords, avatarURL = table.unpack(entries)

        playerCoords = playerCoords or { 0, 0, 0 }

        formattedOfficers[index] = {
            id = tostring(playerId),
            name = playerName, 
            avatarURL = avatarURL,
            policeRank = policeRank,
            inService = inService,
            serviceTime = 0,
            coords = {
                x = playerCoords[1] or playerCoords.x or 0,
                y = playerCoords[2] or playerCoords.y or 0,
                z = playerCoords[3] or playerCoords.z or 0
            }
        }
    end

    callback(formattedOfficers)
end)

RegisterNUICallback('getOfficersOnMap', function(data, callback)
    local formattedOfficersCoords = {}
    local officersCoordsEntries = apiServer.getOfficersCoordinates()

    for index, entries in ipairs(officersCoordsEntries) do
        local playerId, playerName, playerCoords, color = table.unpack(entries)

        formattedOfficersCoords[index] = {
            id = tostring(playerId), 
            name = playerName, 
            color = color, 
            coords = {
                x = playerCoords[1],
                y = playerCoords[2],
                z = playerCoords[3]
            }
        }
    end

    callback(formattedOfficersCoords)
end)

function updateOfficersOnMap(officersCoordsEntries)
    local formattedOfficersCoords = {}

    for index, entries in ipairs(officersCoordsEntries) do
        local playerId, playerName, playerCoords, color = table.unpack(entries)

        formattedOfficersCoords[index] = {
            id = playerId, 
            name = playerName, 
            color = color, 
            coords = {
                x = playerCoords[1],
                y = playerCoords[2],
                z = playerCoords[3]
            }
        }
    end

    SendNUIMessage({
        action = 'updateOfficersOnMap',
        data = formattedOfficersCoords
    })
end

RegisterNetEvent('cc_mdt:updateOfficersOnMap', updateOfficersOnMap)
