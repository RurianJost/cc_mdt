local ReportsCache = {}

function saveReport(createdBy, description, reportCoords)
    if not __isAuth__ then
        return
    end

    local reportId = #ReportsCache + 1

    table.insert(ReportsCache, {
        id = reportId, 
        createdBy = createdBy, 
        description = description, 
        handledBy = nil, 
        coords = { reportCoords.x, reportCoords.y, reportCoords.z }
    })
end

exports('saveReport', saveReport)

function api.getReportById(reportId)
    if not __isAuth__ then
        return
    end

    for _, report in ipairs(ReportsCache) do
        if report.id == reportId then
            return report
        end
    end
end

function api.getReportCoordsById(reportId)
    if not __isAuth__ then
        return
    end

    for _, report in ipairs(ReportsCache) do
        if report.id == reportId then
            return report.coords
        end
    end
end

function api.getServerReports()
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local formattedReports = {}

    for index, report in ipairs(ReportsCache) do
        formattedReports[index] = {
            report.id, 
            report.createdBy, 
            report.description, 
            report.handledBy, 
            report.coords
        }
    end

    return formattedReports
end