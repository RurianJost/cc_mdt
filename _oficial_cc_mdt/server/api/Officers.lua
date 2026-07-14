function api.getOfficerCoordinates(officerId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local officeSource = executeAdapter('getSourceFromPlayerId', officerId)

    if officeSource then
        local officerPed = GetPlayerPed(officeSource)

        if officerPed and DoesEntityExist(officerPed) then
            local officerCoordinates = GetEntityCoords(officerPed)

            return {
                officerCoordinates.x, 
                officerCoordinates.y, 
                officerCoordinates.z
            }
        end
    end
end

function api.getOfficersCoordinates()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source

    local formattedOfficersCoords = {}

    -- playerId, playerName, playerCoords

    return formattedOfficersCoords
end

function api.getServerOfficers()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    
    local serverPolices = executeAdapter('getServerPolices')

    local formattedOfficers = {}

    -- playerId, playerName, policeRank, inService, playerCoords

    return formattedOfficers
end

function api.deleteOfficer(officerId)
    if not __isAuth__ then
        return
    end

    local playerSource = source

    return false, 'Error'
end