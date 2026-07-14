local function getPlayerCoordsBySource(playerSource)
    if not playerSource then
        return nil
    end

    local officerPed = GetPlayerPed(playerSource)

    if not officerPed or officerPed <= 0 or not DoesEntityExist(officerPed) then
        return nil
    end

    local officerCoordinates = GetEntityCoords(officerPed)

    if not officerCoordinates then
        return nil
    end

    local x = tonumber(officerCoordinates.x)
    local y = tonumber(officerCoordinates.y)
    local z = tonumber(officerCoordinates.z)

    if not x or not y or not z then
        return nil
    end

    return { x, y, z }
end

local function normalizeOfficerId(officerId)
    if officerId == nil or officerId == '' then
        return nil
    end

    return tonumber(officerId) or tostring(officerId)
end

local function isSameOfficer(firstOfficerId, secondOfficerId)
    return tostring(firstOfficerId) == tostring(secondOfficerId)
end

local function validateManagedOfficer(actorId, targetOfficerId, policeOrganization)
    local targetIsPolice, targetOrganization, targetHierarchy = executeAdapter('isPlayerPoliceById', targetOfficerId)

    if not targetIsPolice then
        return false, LANGUAGE.OFFICER_TARGET_NOT_POLICE
    end

    if targetOrganization ~= policeOrganization then
        return false, LANGUAGE.OFFICER_TARGET_OTHER_ORGANIZATION
    end

    local _, _, actorHierarchy = executeAdapter('isPlayerPoliceById', actorId, policeOrganization)
    local actorRank = tonumber(actorHierarchy)
    local targetRank = tonumber(targetHierarchy)

    if actorRank and targetRank and targetRank <= actorRank then
        return false, LANGUAGE.OFFICER_TARGET_RANK_PROTECTED
    end

    return true, targetOrganization, targetRank
end

function api.getOfficerCoordinates(officerId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local officeSource = executeAdapter('getSourceFromPlayerId', officerId)

    if officeSource then
        local officerCoords = getPlayerCoordsBySource(officeSource)

        if officerCoords then
            return officerCoords
        end
    end
end

function api.getOfficersCoordinates()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end

    local formattedOfficersCoords = {}
    local serverPolices = executeAdapter('getOnlinePolicesInService', policeOrganization)

    local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization] or {}

    for _, player in ipairs(serverPolices) do
        local officerCoords = getPlayerCoordsBySource(player.source)

        if officerCoords then
            local officerName = executeAdapter('getPlayerName', player.id)

            table.insert(formattedOfficersCoords, {
                player.id,
                officerName,
                officerCoords, 
                ORG_CONFIG.MAP_COLOR or '#0000ff'
            })
        end
    end

    return formattedOfficersCoords
end

function api.getServerOfficers()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return {}
    end
    
    local formattedOfficers = {}
    local serverPolices = executeAdapter('getPolices', policeOrganization)

    for _, playerId in ipairs(serverPolices) do
        local playerSource = executeAdapter('getSourceFromPlayerId', playerId)
        local officerName = executeAdapter('getPlayerName', playerId) or LANGUAGE.COMMON_UNDEFINED
        local policeRank = executeAdapter('getPlayerPoliceRanking', playerId)
        local inService = playerSource and executeAdapter('isPlayerInService', playerSource) or false
        local officerCoords = playerSource and getPlayerCoordsBySource(playerSource) or { 0, 0, 0 }
        local avatarURL = ProfilePhotos:GetPhoto(playerId)

        table.insert(formattedOfficers, {
            playerId,
            officerName,
            policeRank,
            inService,
            officerCoords, 
            avatarURL
        })
    end

    return formattedOfficers
end

function api.fireOfficer(officerId) -- Demitir
    if not __isAuth__ then
        return
    end

    officerId = normalizeOfficerId(officerId)

    if not officerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)

    if isSameOfficer(playerId, officerId) then
        return false, LANGUAGE.OFFICER_SELF_FIRE
    end

    local canFire = executeAdapter('canFirePolice', playerSource, policeOrganization)

    if not canFire then
        return false, LANGUAGE.OFFICER_NO_PERMISSION_FIRE
    end

    local canManage, errorMessage = validateManagedOfficer(playerId, officerId, policeOrganization)

    if not canManage then
        return false, errorMessage
    end

    executeAdapter('firePolice', officerId, policeOrganization)

    return true
end

function api.promoteOfficer(officerId) -- Promover
    if not __isAuth__ then
        return
    end

    officerId = normalizeOfficerId(officerId)

    if not officerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)

    if isSameOfficer(playerId, officerId) then
        return false, LANGUAGE.OFFICER_SELF_PROMOTE
    end

    local canPromote = executeAdapter('canPromotePolice', playerSource, policeOrganization)

    if not canPromote then
        return false, LANGUAGE.OFFICER_NO_PERMISSION_PROMOTE
    end

    local canManage, errorMessage, targetRank = validateManagedOfficer(playerId, officerId, policeOrganization)

    if not canManage then
        return false, errorMessage
    end

    if targetRank and targetRank <= 1 then
        return false, LANGUAGE.OFFICER_HIGHEST_RANK
    end

    executeAdapter('promotePolice', officerId, policeOrganization)

    return true
end

function api.demoteOfficer(officerId) -- Rebaixar
    if not __isAuth__ then
        return
    end

    officerId = normalizeOfficerId(officerId)

    if not officerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)

    if isSameOfficer(playerId, officerId) then
        return false, LANGUAGE.OFFICER_SELF_DEMOTE
    end

    local canDemote = executeAdapter('canDemotePolice', playerSource, policeOrganization)

    if not canDemote then
        return false, LANGUAGE.OFFICER_NO_PERMISSION_DEMOTE
    end

    local canManage, errorMessage = validateManagedOfficer(playerId, officerId, policeOrganization)

    if not canManage then
        return false, errorMessage
    end

    executeAdapter('demotePolice', officerId, policeOrganization)

    return true
end

function api.hireOfficer(officerId) -- Contratar
    if not __isAuth__ then
        return
    end

    officerId = normalizeOfficerId(officerId)

    if not officerId then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local playerSource = source
    local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end
    
    local playerId = executeAdapter('getPlayerId', playerSource)

    if isSameOfficer(playerId, officerId) then
        return false, LANGUAGE.OFFICER_SELF_HIRE
    end

    local canHire = executeAdapter('canHirePolice', playerSource, policeOrganization)

    if not canHire then
        return false, LANGUAGE.OFFICER_NO_PERMISSION_HIRE
    end

    local targetIsPolice = executeAdapter('isPlayerPoliceById', officerId)

    if targetIsPolice then
        return false, LANGUAGE.OFFICER_ALREADY_POLICE
    end

    local targetSource = executeAdapter('getSourceFromPlayerId', officerId)

    if not targetSource then
        return false, LANGUAGE.OFFICER_NOT_ONLINE
    end

    local targetAccept = apiClient.createRequest(targetSource, LANGUAGE.OFFICER_HIRE_REQUEST_TITLE, LANGUAGE.OFFICER_HIRE_REQUEST_DESCRIPTION)

    if not targetAccept then
        return false, LANGUAGE.OFFICER_HIRE_REQUEST_REJECTED
    end

    executeAdapter('hirePolice', officerId, policeOrganization)

    return true
end
