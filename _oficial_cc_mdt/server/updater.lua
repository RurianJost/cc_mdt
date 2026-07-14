if not LPH_OBFUSCATED then
    return
end

local REFRESH_INTERVAL = 600000
local STARTUP_DELAY = 2000

local resourceName = GetCurrentResourceName()
local resourcePath = GetResourcePath(resourceName)
local versionCache = {}

local function resolvePath(file)
    return resourcePath .. '/' .. file
end

local function endpoint(route)
    return ('https://rkg_updater.purplesolutions.com.br' .. route)
end

local function urlEncode(value)
    return (string.gsub(value, '([^%w%-_%.~])', function(c)
        return string.format('%%%02X', string.byte(c))
    end))
end

local function readFile(path, mode)
    local f = io.open(path, mode or 'r')

    if not f then
        return nil
    end

    local data = f:read('*all')

    f:close()

    return data
end

local function writeToFile(path, data, mode)
    local f = io.open(path, mode or 'w')

    if not f then
        return false
    end

    f:write(data)
    f:close()

    return true
end

local function httpRequest(url, method, body, headers)
    local p = promise.new()

    local callback = function(code, data)
        p:resolve({ code = code, data = data })
    end

    PerformHttpRequest(url, callback, method, body, headers or {})

    return Citizen.Await(p)
end

local function loadVersionCache()
    local raw = readFile(resolvePath('.versions'))

    if not raw then
        return {}
    end

    local parsed = json.decode(raw)

    return (type(parsed) == 'table') and parsed or {}
end

local function persistVersionCache()
    writeToFile(resolvePath('.versions'), json.encode(versionCache))
end

local function collectWatchEntries()
    local entries = {}
    local total = GetNumResourceMetadata(resourceName, 'watch_file')

    for idx = 0, total - 1 do
        local val = GetResourceMetadata(resourceName, 'watch_file', idx)

        if val then
            entries[#entries + 1] = val
        end
    end

    return entries
end

local function buildPayload(entries)
    local payload = {}

    for i = 1, #entries do
        payload[#payload + 1] = {
            path = entries[i],
            version = versionCache[entries[i]]
        }
    end

    return payload
end

local function checkForUpdates(payload)
    local url = endpoint('/status/' .. resourceName)
    local body = json.encode(payload)

    local res = httpRequest(url, 'POST', body, {['Content-Type'] = 'application/json' })

    if res.code ~= 200 then
        return {}
    end

    return json.decode(res.data) or {}
end

local function applyUpdate(fileInfo)
    local url = endpoint('/files/' .. resourceName .. '?path=' .. urlEncode(fileInfo.path))
    local res = httpRequest(url, 'POST', '{}', { ['Content-Type'] = 'application/json' })

    if res.code ~= 200 then
        return false
    end

    local payload = json.decode(res.data)

    if type(payload) ~= 'table' or type(payload.content) ~= 'string' then
        return false
    end

    local target = resolvePath(fileInfo.path)

    os.remove(target)

    if not writeToFile(target, payload.content, 'wb') then
        return false
    end

    print('^6[UPDATER]^0 ' .. fileInfo.path .. ' - ' .. fileInfo.version)

    versionCache[fileInfo.path] = fileInfo.version

    return true
end

local function processUpdateCycle(entries)
    local payload = buildPayload(entries)

    if #payload == 0 then
        return
    end

    local updates = checkForUpdates(payload)
    local dirty = false

    for i = 1, #updates do
        if applyUpdate(updates[i]) then
            dirty = true
        end
    end

    if dirty then
        persistVersionCache()
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(STARTUP_DELAY)

    versionCache = loadVersionCache()

    local entries = collectWatchEntries()

    while true do
        processUpdateCycle(entries)

        Citizen.Wait(REFRESH_INTERVAL)
    end
end)