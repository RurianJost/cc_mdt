RegisterNUICallback('updateRegister', function(data, callback)
    local suspectId = data.suspect and data.suspect.id
    local status, resultEntries = apiServer.updateRegister(data.id, suspectId, data.crimes or {})
    
    if not status then
        return callback({ errorMessage = resultEntries })
    end
    
    local formattedCrimes = {}
    local playerId, suspectId, suspectDescription, isFinished, sentence, fine, bailAmount, crimes = table.unpack(resultEntries)
    
    for _, crimeId in ipairs(crimes) do
        table.insert(formattedCrimes, { id = crimeId })
    end

    callback({
        newData = {
            id = playerId,
            isFinished = isFinished,
            description = suspectDescription,
            sentence = sentence,
            fine = fine,
            bailAmount = bailAmount,
            crimes = formattedCrimes,
            suspect = {
                id = suspectId
            }
        }
    })
end)

RegisterNUICallback('finishRegister', function(data, callback)
    local status, errorMessage = apiServer.finishRegister(data.id)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('deleteRegister', function(data, callback)
    local status, errorMessage = apiServer.deleteRegister(data.id)

    callback({
        errorMessage = errorMessage
    })
end)

RegisterNUICallback('getRegistersData', function(data, callback)
    local formattedRegisters = {}
    local registerEntries = apiServer.getServerRegisters()

    for index, entries in ipairs(registerEntries) do
        local registerId, officerId, officerName, suspectId, suspectName, suspectIdentity, crimes, description, sentence, fine, bailAmount, formattedDate, isFinished = table.unpack(entries)

        local formattedCrimes = {}

        for _, crimeId in ipairs(crimes) do
            table.insert(formattedCrimes, {
                id = crimeId
            })
        end

        formattedRegisters[index] = {
            id = registerId,
            police = {
                name = officerName,
                id = officerId,
            },
            formattedDate = formattedDate,
            suspect = {
                name = suspectName,
                id = suspectId,
                identity = suspectIdentity,
            },
            isFinished = isFinished, -- Opcional
            crimes = formattedCrimes,
            description = description,
            sentence = sentence,
            fine = fine,
            bailAmount = bailAmount, -- Opcional
        }
    end

    callback(formattedRegisters)
end)