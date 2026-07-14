local CommunicationsCache = {}
local LastCommunicationMessageAt = {}
local COMMUNICATIONS_CACHE_LIMIT = 100
local COMMUNICATION_MESSAGE_MAX_LENGTH = 255
local COMMUNICATION_MESSAGE_COOLDOWN_SECONDS = 2

local function normalizeCommunicationMessage(messageContent)
    if type(messageContent) ~= 'string' then
        return nil
    end

    local message = messageContent:gsub('[\r\n]+', ' '):gsub('^%s+', ''):gsub('%s+$', '')

    if message == '' then
        return nil
    end

    return message:sub(1, COMMUNICATION_MESSAGE_MAX_LENGTH)
end

local function canSendCommunicationMessage(playerSource)
    local currentTime = os.time()
    local lastMessageAt = LastCommunicationMessageAt[playerSource]

    if lastMessageAt and (currentTime - lastMessageAt) < COMMUNICATION_MESSAGE_COOLDOWN_SECONDS then
        return false
    end

    LastCommunicationMessageAt[playerSource] = currentTime

    return true
end

local function trimCommunicationsCache()
    while #CommunicationsCache > COMMUNICATIONS_CACHE_LIMIT do
        table.remove(CommunicationsCache, 1)
    end
end

function api.getCommunications()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    return CommunicationsCache
end

function api.sendCommunicationMessage(messageContent)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    messageContent = normalizeCommunicationMessage(messageContent)

    if not messageContent or not canSendCommunicationMessage(playerSource) then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local avatarURL = ProfilePhotos:GetPhoto(playerId)

    table.insert(CommunicationsCache, { playerId, playerName, messageContent, avatarURL })

    trimCommunicationsCache()

    local openInterfaces = Interface:GetAllOpenInterfaces()

    for targetSource, targetEntries in pairs(openInterfaces) do
        TriggerClientEvent('cc_mdt:insertNewCommunicationMessage', targetSource, playerId, playerName, messageContent, avatarURL)
    end
end
