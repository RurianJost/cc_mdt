local ReportsCache = {}
local NextReportId = 1

local function isValidNumber(value)
    return type(value) == 'number'
end

local function normalizeCoords(reportCoords)
    if type(reportCoords) ~= 'table' then
        return nil
    end

    local x = reportCoords.x or reportCoords[1]
    local y = reportCoords.y or reportCoords[2]
    local z = reportCoords.z or reportCoords[3]

    if not isValidNumber(x) or not isValidNumber(y) or not isValidNumber(z) then
        return nil
    end

    return { x, y, z }
end

local function formatReportEntries(report)
    return {
        report.id,
        report.createdBy,
        report.description,
        report.handledBy,
        report.coords
    }
end

local function getReportIndexById(reportId)
    local targetReportId = tonumber(reportId)

    if not targetReportId then
        return nil
    end

    for index, report in ipairs(ReportsCache) do
        if report.id == targetReportId then
            return index
        end
    end

    return nil
end

local function getReportByIdInternal(reportId)
    local reportIndex = getReportIndexById(reportId)

    if not reportIndex then
        return nil
    end

    return ReportsCache[reportIndex], reportIndex
end

local function createReportInternal(createdBy, description, reportCoords)
    local formattedCreatedBy = tostring(createdBy or LANGUAGE.COMMON_UNDEFINED)
    local formattedDescription = tostring(description or ''):gsub('^%s+', ''):gsub('%s+$', '')
    local formattedCoords = normalizeCoords(reportCoords)

    if formattedDescription == '' then
        return false, LANGUAGE.REPORT_DESCRIPTION_INVALID
    end

    if not formattedCoords then
        return false, LANGUAGE.REPORT_COORDS_INVALID
    end

    local report = {
        id = NextReportId,
        createdBy = formattedCreatedBy,
        description = formattedDescription,
        handledBy = false,
        coords = formattedCoords
    }

    NextReportId = NextReportId + 1

    table.insert(ReportsCache, report)

    local openInterfaces = Interface:GetAllOpenInterfaces()

    for targetSource, _ in pairs(openInterfaces) do
        TriggerClientEvent('cc_mdt:insertNewReport', targetSource, formatReportEntries(report))
    end

    return true, report
end

local function handleReportInternal(reportId, handledBy)
    local report, reportIndex = getReportByIdInternal(reportId)

    if not report then
        return false, LANGUAGE.REPORT_NOT_FOUND
    end

    local formattedHandledBy = tostring(handledBy or LANGUAGE.COMMON_UNDEFINED)

    ReportsCache[reportIndex].handledBy = formattedHandledBy

    return true, ReportsCache[reportIndex]
end

local function getReportsInternal()
    local formattedReports = {}

    for index, report in ipairs(ReportsCache) do
        formattedReports[index] = formatReportEntries(report)
    end

    return formattedReports
end

local function deleteReportInternal(reportId)
    local report, reportIndex = getReportByIdInternal(reportId)

    if not report then
        return false, LANGUAGE.REPORT_NOT_FOUND
    end

    table.remove(ReportsCache, reportIndex)

    return true, report
end

local function createReport(createdBy, description, reportCoords)
    local success, reportOrMessage = createReportInternal(createdBy, description, reportCoords)

    if not success then
        return false, reportOrMessage
    end

    return true, reportOrMessage.id
end

local function handleReport(reportId, handledBy)
    local success, reportOrMessage = handleReportInternal(reportId, handledBy)

    if not success then
        return false, reportOrMessage
    end

    return true
end

local function getReports()
    return getReportsInternal()
end

local function deleteReport(reportId)
    local success, reportOrMessage = deleteReportInternal(reportId)

    if not success then
        return false, reportOrMessage
    end

    return true
end

exports('createReport', createReport)
exports('handleReport', handleReport)
exports('getReports', getReports)
exports('deleteReport', deleteReport)

function api.getReportById(reportId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local report = getReportByIdInternal(reportId)

    return report
end

function api.acceptReport(reportId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return
    end

    local report = getReportByIdInternal(reportId)

    if report then
        if not report.handledBy then
            local playerName = executeAdapter('getPlayerName', playerId)

            report.handledBy = LANGUAGE.REPORT_HANDLED_BY_FORMAT:format(playerId, playerName)

            TriggerClientEvent('cc_mdt:acceptReport', playerSource, report.id, report.createdBy, report.description, report.coords)

            local formattedReport = getReportsInternal()
            local openInterfaces = Interface:GetAllOpenInterfaces()

            for targetSource, _ in pairs(openInterfaces) do
                TriggerClientEvent('cc_mdt:updateAllReports', targetSource, formattedReport)
            end
        else
            executeAdapter('notifyPlayer', playerSource, LANGUAGE.REPORT_ACCEPTED_BY_OTHER)
        end
    end
end

function api.getServerReports()
    if not __isAuth__ then
        return {}
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    return getReportsInternal()
end

function api.handleReport(reportId, handledBy)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local finalHandledBy = handledBy

    if not finalHandledBy then
        local playerId = executeAdapter('getPlayerId', playerSource)

        finalHandledBy = executeAdapter('getPlayerName', playerId)
    end

    local success, reportOrMessage = handleReportInternal(reportId, finalHandledBy)

    if not success then
        return false, reportOrMessage
    end

    return true, formatReportEntries(reportOrMessage)
end

function api.deleteReport(reportId)
    if not __isAuth__ then
        return
    end

    local playerSource = source
    local isPolice = executeAdapter('isPlayerPolice', playerSource)

    if not isPolice then
        return
    end

    local success, errorMessage = deleteReportInternal(reportId)

    return success, (not success and errorMessage)
end
