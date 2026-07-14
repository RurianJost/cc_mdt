RegisterNUICallback('getOccurrenceData', function(data, callback)
    local userData, vehiclesData, occurrencesData, vehicleFines
    local resultType, resultEntries, occurrencesEntries = apiServer.getOccurrenceFromSearch(data.search)

    if resultType == 'NOT_FOUND' then
        callback({
            errorMessage = LANGUAGE.OCCURRENCE_SEARCH_NOT_FOUND,
        })

        return
    end

    if resultType == 'USER' then
        local playerId, playerName, playerAvatarURL, playerAge, playerIdentity, playerFineValue = table.unpack(resultEntries)

        userData = {
            id = playerId,
            name = playerName,
            age = playerAge,
            identity = playerIdentity,
            avatarURL = playerAvatarURL, 
            fineValue = playerFineValue
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

        vehicleFines = {}

        for index, entries in ipairs(occurrencesEntries) do
            local fineId, fineDescription, createdAt, officerName, officerId, fineValue, fineStatus = table.unpack(entries)

            table.insert(vehicleFines, {
                id = fineId,
                title = fineDescription,
                createdAt = createdAt,
                officer = {
                    name = officerName,
                    id = officerId,
                },
                fine = fineValue,
                status = fineStatus
            })
        end
    end

    callback({
        user = userData, 
        fines = vehicleFines, 
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