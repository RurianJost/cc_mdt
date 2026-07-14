-- SetNuiFocus()
-- SendNUIMessage({})
-- SetNuiFocusKeepInput()

function openInterface()
    apiServer.playerOpenInterface()
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setVisible',
        data = true
    })
end

function closeInterface()
    apiServer.playerClosedInterface()
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })
end

function updateUserData(playerId, playerName, policeRank, inService)
    local avatarURL
    local headshotTxd = Headshot:GetPedHeadshot()

    if headshotTxd and type(headshotTxd) == 'string' then
        avatarURL = 'https://nui-img/'..tostring(headshotTxd)..'/'..tostring(headshotTxd)
    end

    SendNUIMessage({
        action = "updateUserData",
        data = {
            id = playerId,
            name = playerName, 
            policeRank = policeRank,
            avatarURL = avatarURL, 
            inService = inService
        }
    })
end

RegisterNUICallback('removeFocus', function(data, callBack)
    SetNuiFocus(false, false)

    apiServer.playerClosedInterface()

    callBack({})
end)

RegisterNUICallback('getUserData', function(data, callback)
    local playerEntries = apiServer.getPlayerData()
    local playerId, playerName, policeRanking, inService = table.unpack(playerEntries)

    local avatarURL
    local headshotTxd = Headshot:GetPedHeadshot()

    if headshotTxd and type(headshotTxd) == 'string' then
        avatarURL = 'https://nui-img/'..tostring(headshotTxd)..'/'..tostring(headshotTxd)
    end

    callback({
        id = playerId,
        name = playerName, 
        policeRank = policeRanking,
        avatarURL = avatarURL, 
        inService = inService
    })
end)

RegisterNUICallback('getPenalCodes', function(data, callback)
    local formattedPenalCodes = {}
    local formattedAttenuants = {}
    local formattedAggravants = {}

    for index, penalCode in ipairs(LEGISLATION_CONFIG.PENAL_CODES) do 
        table.insert(formattedPenalCodes, {
            id = index,
            article = penalCode.ARTICLE,
            description = penalCode.NAME,
            sentence = penalCode.SENTENCE,
            fine = penalCode.FINE,
        })
    end

    for index, attenuant in ipairs(LEGISLATION_CONFIG.ATTENUANTS_FACTORS) do 
        table.insert(formattedAttenuants, {
            id = index,
            percentage = attenuant.PERCENTAGE,
            description = attenuant.NAME,
        })
    end

    for index, aggravant in ipairs(LEGISLATION_CONFIG.AGGRAVATING_FACTORS) do 
        table.insert(formattedAggravants, {
            id = index,
            percentage = aggravant.PERCENTAGE,
            description = aggravant.NAME,
        })
    end

    callback({
        data = formattedPenalCodes, 
        attenuants = formattedAttenuants, 
        aggravants = formattedAggravants, 
    })
end)

RegisterNUICallback('markCds', function(data, callback)
    local officerCoordinates = apiServer.getOfficerCoordinates(data.officerId)

    if officerCoordinates then
        executeAdapter('createOfficerBlipLocation', { 
            x = officerCoordinates[1], 
            y = officerCoordinates[2], 
            z = officerCoordinates[3] 
        })
    end

    callback({})
end)