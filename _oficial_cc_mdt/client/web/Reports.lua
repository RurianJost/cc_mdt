function insertNewReport(reportEntries)
    local reportId, createdBy, description, handledBy, reportCoords = table.unpack(reportEntries)

    SendNUIMessage({
        action = 'updateNewReport',
        data = {
            id = reportId,
            createdBy = createdBy,
            description = description,
            handledBy = handledBy or LANGUAGE.REPORT_NOT_ANSWERED,
            coords = {
                x = reportCoords[1],
                y = reportCoords[2],
                z = reportCoords[3]
            }
        }
    })
end

function updateAllReports(reportEntries)
    local formattedReports = {}

    for index, entries in ipairs(reportEntries) do
        local reportId, createdBy, description, handledBy, reportCoords = table.unpack(entries)

        formattedReports[index] = {
            id = reportId,
            createdBy = createdBy,
            description = description,
            handledBy = handledBy or LANGUAGE.REPORT_NOT_ANSWERED,
            coords = {
                x = reportCoords[1],
                y = reportCoords[2],
                z = reportCoords[3]
            }
        }
    end

    SendNUIMessage({
        action = 'updateAllReports',
        data = formattedReports
    })
end

RegisterNUICallback('acceptReport', function(data, callback)
    apiServer.acceptReport(data.id)

    callback({})
end)

RegisterNUICallback('getAllReports', function(_, callback)
    local formattedReports = {}
    local reportEntries = apiServer.getServerReports()

    for index, entries in ipairs(reportEntries) do
        local reportId, createdBy, description, handledBy, reportCoords = table.unpack(entries)

        formattedReports[index] = {
            id = reportId,
            createdBy = createdBy,
            description = description,
            handledBy = handledBy,
            coords = {
                x = reportCoords[1],
                y = reportCoords[2],
                z = reportCoords[3]
            }
        }
    end

    callback(formattedReports)
end)

RegisterNetEvent('cc_mdt:insertNewReport', insertNewReport)
RegisterNetEvent('cc_mdt:updateAllReports', updateAllReports)
RegisterNetEvent('cc_mdt:acceptReport', function(reportId, createdBy, description, coords)
    executeAdapter('onPlayerAcceptReport', reportId, createdBy, description, coords)
end)
