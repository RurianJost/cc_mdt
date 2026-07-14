local ChatCache = {}

function api.getChatMessages()
    if not __isAuth__ then
        return {}
    end

    return ChatCache
end

function api.sendMessageInChat(messageContent)
    if not __isAuth__ then
        return
    end

    if #messageContent == 0 or messageContent == '' then
        return
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)

    table.insert(ChatCache, { playerId, playerName, messageContent })

    local openInterfaces = Interface:GetAllOpenInterfaces()

    for _, targetSource in ipairs(openInterfaces) do
        TriggerClientEvent('cc_mdt:insertNewChatMessage', targetSource, playerId, playerName, messageContent)
    end
end