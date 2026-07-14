-- Usar isso aqui para criar um comando? Tipo /call
function insertNewReport(reportEntries)
    local reportId, createdBy, description, handledBy, reportCoords = table.unpack(reportEntries)

    SendNUIMessage({
        action = 'updateNewReport',
        data = {
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
            handledBy = handledBy,
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

RegisterNUICallback('markReportCds', function(data, callback)
    local reportCoords = apiServer.getReportCoordsById(data.id)

    if reportCoords then
        executeAdapter('createReportBlipLocation', {
            x = reportCoords[1],
            y = reportCoords[2],
            z = reportCoords[3]
        })
    end

    callback({})
end)

RegisterNUICallback('getAllReports', function(data, callback)
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