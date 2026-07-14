local DEFAULT_PANEL_PRIMARY_COLOR = '#7289DA'

local function getNonEmptyString(value)
    if type(value) ~= 'string' or value == '' then
        return nil
    end

    return value
end

local function getValidPanelColor(value)
    if type(value) == 'string' and value:match('^#%x%x%x%x%x%x$') then
        return value
    end

    return nil
end

local function getOrganizationPanelConfig(policeOrganization)
    local generalPanel = GENERAL_CONFIG.PANEL or {}
    local organizationConfig = ORGANIZATIONS_CONFIG[policeOrganization] or {}
    local organizationPanel = organizationConfig.PANEL or {}
    local logoURL = getNonEmptyString(organizationPanel.LOGO_URL)
        or getNonEmptyString(generalPanel.LOGO_URL)
        or getNonEmptyString(GENERAL_CONFIG.SERVER_LOGO_URL)
        or ''
    local primaryColor = getValidPanelColor(organizationPanel.PRIMARY_COLOR)
        or getValidPanelColor(generalPanel.PRIMARY_COLOR)
        or DEFAULT_PANEL_PRIMARY_COLOR

    return logoURL, primaryColor
end

function api.canOpenPainel()
    if not __isAuth__ then
        return
    end

    local playerSource = source

    return executeAdapter('canOpenPainel', playerSource)
end

function api.playerOpenInterface()
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    Interface:OnPlayerOpen(playerSource)
end

function api.playerClosedInterface()
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    Interface:OnPlayerClose(playerSource)
end

function api.updateAvatarURL(avatarURL)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)
    
    if playerId then
        ProfilePhotos:SetPhoto(playerId, avatarURL)
        
        local playerName = executeAdapter('getPlayerName', playerId)
        local policeRanking = executeAdapter('getPlayerPoliceRanking', playerId)    
        local inService = executeAdapter('isPlayerInService', playerSource)
        local canManageOfficers = executeAdapter('canManageOfficers', playerSource, policeOrganization)
        local panelLogoURL, panelPrimaryColor = getOrganizationPanelConfig(policeOrganization)

        TriggerClientEvent('cc_mdt:updateUserData', playerSource, playerId, playerName, policeRanking, inService, avatarURL, canManageOfficers, policeOrganization, panelLogoURL, panelPrimaryColor)
    end
end

function api.getPlayerData()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    local playerId = executeAdapter('getPlayerId', playerSource)
    local playerName = executeAdapter('getPlayerName', playerId)
    local policeRanking = executeAdapter('getPlayerPoliceRanking', playerId)    
    local inService = executeAdapter('isPlayerInService', playerSource)
    local avatarURL = ProfilePhotos:GetPhoto(playerId)
    local canManageOfficers = executeAdapter('canManageOfficers', playerSource, policeOrganization)
    local panelLogoURL, panelPrimaryColor = getOrganizationPanelConfig(policeOrganization)

    return {
        playerId,
        playerName,
        policeRanking,
        inService, 
        avatarURL, 
        canManageOfficers,
        policeOrganization,
        panelLogoURL,
        panelPrimaryColor
    }
end

function api.startPrisonTask(taskIndex)
    if not __isAuth__ then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    return Prison:StartTask(playerSource, playerId, taskIndex)
end

function api.reducePrisonSentence(taskIndex)
    if not __isAuth__ then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local success, sentence, releaseTick = Prison:CompleteTask(playerSource, playerId, taskIndex)

    if not success then
        return false, sentence
    end

    return true, sentence, releaseTick
end
