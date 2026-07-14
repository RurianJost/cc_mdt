local ChatCache = {}
local LastChatMessageAt = {}
local CHAT_CACHE_LIMIT = 100
local CHAT_MESSAGE_MAX_LENGTH = 255
local CHAT_MESSAGE_COOLDOWN_SECONDS = 2

local function normalizeChatMessage(messageContent)
    if type(messageContent) ~= 'string' then
        return nil
    end

    local message = messageContent:gsub('[\r\n]+', ' '):gsub('^%s+', ''):gsub('%s+$', '')

    if message == '' then
        return nil
    end

    return message:sub(1, CHAT_MESSAGE_MAX_LENGTH)
end

local function canSendChatMessage(playerSource)
    local currentTime = os.time()
    local lastMessageAt = LastChatMessageAt[playerSource]

    if lastMessageAt and (currentTime - lastMessageAt) < CHAT_MESSAGE_COOLDOWN_SECONDS then
        return false
    end

    LastChatMessageAt[playerSource] = currentTime

    return true
end

local function trimChatCache()
    while #ChatCache > CHAT_CACHE_LIMIT do
        table.remove(ChatCache, 1)
    end
end

function api.getChatMessages()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    return ChatCache
end

function api.sendMessageInChat(messageContent)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    messageContent = normalizeChatMessage(messageContent)

    if not messageContent or not canSendChatMessage(playerSource) then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local avatarURL = ProfilePhotos:GetPhoto(playerId)

    table.insert(ChatCache, { playerId, playerName, messageContent, avatarURL })

    trimChatCache()

    local openInterfaces = Interface:GetAllOpenInterfaces()

    for targetSource, targetEntries in pairs(openInterfaces) do
        TriggerClientEvent('cc_mdt:insertNewChatMessage', targetSource, playerId, playerName, messageContent, avatarURL)
    end
end
