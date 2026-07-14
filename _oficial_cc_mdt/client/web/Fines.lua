RegisterNUICallback('getFines', function(data, callback)
    local formattedFines = {}

    for index, fineData in ipairs(LEGISLATION_CONFIG.TRAFFIC_TICKETS) do 
        table.insert(formattedFines, {
            id = index,
            article = fineData.ARTICLE,
            description = fineData.NAME,
            value = fineData.FINE
        })
    end

    callback({
        fines = formattedFines
    })
end)

RegisterNUICallback('applyVehicleFine', function(data, callback)
    apiServer.applyVehicleFine(data.vehiclePlate, data.fines)

    callback({})
end)