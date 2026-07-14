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

local function getOrganizationCommunicationsCache(policeOrganization)
    if not CommunicationsCache[policeOrganization] then
        CommunicationsCache[policeOrganization] = {}
    end

    return CommunicationsCache[policeOrganization]
end

local function trimCommunicationsCache(organizationCache)
    while #organizationCache > COMMUNICATIONS_CACHE_LIMIT do
        table.remove(organizationCache, 1)
    end
end

function api.getCommunications()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice or not policeOrganization then
        return {}
    end

    return getOrganizationCommunicationsCache(policeOrganization)
end

function api.sendCommunicationMessage(messageContent)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice or not policeOrganization then
        return
    end

    messageContent = normalizeCommunicationMessage(messageContent)

    if not messageContent or not canSendCommunicationMessage(playerSource) then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local avatarURL = ProfilePhotos:GetPhoto(playerId)

    local organizationCache = getOrganizationCommunicationsCache(policeOrganization)

    table.insert(organizationCache, { playerId, playerName, messageContent, avatarURL })

    trimCommunicationsCache(organizationCache)

    local openInterfaces = Interface:GetAllOpenInterfaces()

    for targetSource in pairs(openInterfaces) do
        local targetIsPolice, targetOrganization = executeAdapter('isPlayerPolice', targetSource)

        if targetIsPolice and targetOrganization == policeOrganization then
            TriggerClientEvent('cc_mdt:insertNewCommunicationMessage', targetSource, playerId, playerName, messageContent, avatarURL)
        end
    end
end
