RegisterNUICallback('sendCommunicationMessage', function(data, callback)
    local messageContent = type(data) == 'table' and data.message or nil

    if type(messageContent) ~= 'string' or messageContent == '' then
        callback('Ok')

        return
    end

    apiServer.sendCommunicationMessage(messageContent)

    callback('Ok')
end)

RegisterNUICallback('getAllCommunications', function(data, callback)
    local formattedChat = {}
    local chatEntries = apiServer.getCommunications()

    for index, entries in ipairs(chatEntries) do
        local playerId, playerName, messageContent, avatarURL = table.unpack(entries)

        formattedChat[index] = {
            id = playerId,
            author = playerName, 
            message = messageContent, 
            avatarURL = avatarURL
        }
    end

    callback(formattedChat)
end)

function insertNewCommunicationMessage(playerId, playerName, messageContent, avatarURL)
    SendNUIMessage({
        action = 'newCommunicationMessage',
        data = {
            id = playerId,
            author = playerName,
            message = messageContent, 
            avatarURL = avatarURL
        }
    })
end

function updateAllCommunications(communicationEntries)
    local formattedChat = {}

    for index, entries in ipairs(communicationEntries) do
        local playerId, playerName, messageContent, avatarURL = table.unpack(entries)

        formattedChat[index] = {
            id = playerId,
            author = playerName, 
            message = messageContent,
            avatarURL = avatarURL
        }
    end

    SendNUIMessage({
        action = 'updateAllCommunications',
        data = formattedChat
    })
end

RegisterNetEvent('cc_mdt:insertNewCommunicationMessage', insertNewCommunicationMessage)
RegisterNetEvent('cc_mdt:updateAllCommunications', updateAllCommunications)
