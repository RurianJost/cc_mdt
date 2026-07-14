RegisterNUICallback('sendCommunicationMessage', function(data, callback)
    local messageContent = data.message

    if #messageContent == 0 or messageContent == '' then
        return
    end

    apiServer.sendMessageInChat(messageContent)

    callback('Ok')
end)

RegisterNUICallback('getAllCommunications', function(data, callback)
    local formattedChat = {}
    local chatEntries = apiServer.getChatMessages()

    for index, entries in ipairs(chatEntries) do
        local playerId, playerName, messageContent = table.unpack(entries)

        formattedChat[index] = {
            id = playerId,
            author = playerName, 
            message = messageContent
        }
    end

    callback(formattedChat)
end)

function insertNewChatMessage(playerId, playerName, messageContent)
    SendNUIMessage({
        action = 'newCommunicationMessage',
        data = {
            id = playerId,
            author = playerName,
            message = messageContent
        }
    })
end

function updateAllChatMessages(chatEntries)
    local formattedChat = {}

    for index, entries in ipairs(chatEntries) do
        local playerId, playerName, messageContent = table.unpack(entries)

        formattedChat[index] = {
            id = playerId,
            author = playerName, 
            message = messageContent
        }
    end

    SendNUIMessage({
        action = 'updateAllCommunications',
        data = formattedChat
    })
end

RegisterNetEvent('cc_mdt:insertNewChatMessage', insertNewChatMessage)
RegisterNetEvent('cc_mdt:updateAllChatMessages', updateAllChatMessages)