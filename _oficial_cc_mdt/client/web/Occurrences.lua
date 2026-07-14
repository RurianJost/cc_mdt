RegisterNUICallback('getOccurrenceData', function(data, callback)
    local userData, vehiclesData, occurrencesData
    local resultType, resultEntries = apiServer.getOccurrenceFromSearch(data.search)

    if resultType == 'NOT_FOUND' then
        callback({
            errorMessage = 'Nenhum resultado encontrado para a busca realizada.',
        })

        return
    end

    if resultType == 'USER' then
        local userEntries, occurrencesEntries = table.unpack(resultEntries)
        local playerId, playerName, playerAvatarURL, playerAge, playerIdentity, playerFineValue, playerStatus = table.unpack(userEntries)

        userData = {
            id = playerId,
            name = playerName,
            age = playerAge,
            identity = playerIdentity,
            avatarURL = playerAvatarURL, 
            fineValue = playerFineValue,
            status = playerStatus,
        }

        occurrencesData = {}

        for index, entries in ipairs(occurrencesEntries) do
            local occurrenceId, occurrenceTitle, occurrenceCreatedAt, officerName, officerId, occurrenceFine, occurrenceStatus = table.unpack(entries)

            table.insert(occurrencesData, {
                id = occurrenceId,
                title = occurrenceTitle,
                createdAt = occurrenceCreatedAt,
                officer = {
                    name = officerName,
                    id = officerId,
                },
                fine = occurrenceFine,
                status = occurrenceStatus,
            })
        end
    elseif resultType == 'VEHICLE' then
        local plate, model, isDetained, imageURL, ownerId, ownerName = table.unpack(resultEntries)

        vehiclesData = {
            plate = plate,
            model = model,
            isDetained = isDetained,
            imageURL = imageURL,
            owner = ownerId and ownerName and {
                id = ownerId,
                name = ownerName
            }
        }
    end

    callback({
        user = userData, 
        vehicle = vehiclesData, 
        occurrences = occurrencesData
    })
end)

RegisterNUICallback('registerOccurrence', function(data, callback)
    local suspectId = data.suspect and data.suspect.id
    local suspectDescription = data.suspect and data.suspect.description
    
    local crimes = data.crimes or {}
    local attenuants = (data.modifiers and data.modifiers.attenuants) or {}
    local aggravants = (data.modifiers and data.modifiers.aggravants) or {}

    local success, errorMessage = apiServer.registerNewOccurrence(suspectId, suspectDescription, crimes, attenuants, aggravants, data.photo)

    callback({
        errorMessage = errorMessage
    })
end)