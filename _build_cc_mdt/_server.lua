local _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL = false

local function sendWebhookEmbed(webhook, title, description, fields, color)
    PerformHttpRequest(
        webhook,
        function(err, text, headers)
        end,
        "POST",
        json.encode(
            {
                embeds = {
                    {
                        title = title,
                        description = description,
                        author = {
                            name = "Carioca Development",
                            icon_url = 'https://imgur.com/a/xL7mWxZ'
                        },
                        fields = fields,
                        footer = {
                            text = os.date("\\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S"),
                            icon_url = "https://imgur.com/a/xL7mWxZ"
                        },
                        color = color
                    }
                }
            }
        ),
        {["Content-Type"] = "application/json"}
    )
end

local function sucesso(body)
    local script = GetCurrentResourceName()

    _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL = true

    local licenseExpiresAt
    
    if body.expiresAt then
        licenseExpiresAt = math.floor(( (body.expiresAt/1000) - os.time() ) /60 /60 /24)
    end
    
    if tonumber(licenseExpiresAt) and licenseExpiresAt <= 0 then
        licenseExpiresAt = math.floor(( (body.expiresAt/1000) - os.time() ) /60 /60)

        print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 horas. By ^2https://discord.gg/78sERGaWQm^0')

        return
    end

    print('^1['..script..'] ^2Autenticado com sucesso!^0 By ^2https://discord.gg/78sERGaWQm^0')

    if licenseExpiresAt then
        if licenseExpiresAt <= 1 then
            print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 dia. By ^2https://discord.gg/78sERGaWQm^0')

            return
        end
        
        print('^1['..script..'] ^3Sua licença irá expirar em ^8'..licenseExpiresAt..'^0 dias. By ^2https://discord.gg/78sERGaWQm^0')
    else
        print('^1['..script..'] ^3Sua licença expirará em nunca ^2(Lifetime)^0. By ^2https://discord.gg/78sERGaWQm^0')
    end
end

local errorsMessages = {
    ['INVALID_IP_ADDRESS'] = 'Ip invalido, verifique o ip novamente',
    ['INVALID_LICENSE'] = 'Token invalido, verifique o token em token.lua',
    ['INVALID_PORT'] = 'Porta incorreta, verifique a porta novamente'
}

local function erro(body)
    local script = GetCurrentResourceName()

    _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL = false

    if body.err == 'LICENSE_EXPIRED' then
        print('['..script..'] ^8A licença expirou, renove a sua licença ou pague as parcelas!^0. By ^2https://discord.gg/78sERGaWQm^0')
    else    
        print('['..script..'] ^8Falha na autenticação^0. By ^2https://discord.gg/78sERGaWQm^0')
    end
    
    if errorsMessages[body.err] then
        print('['..script..'] '..tostring(errorsMessages[body.err]))
    end

    if body.err == 'INVALID_TOKEN' then 
        local sv_hostname = GetConvar('sv_hostname', 'Not found')
        local sv_master = GetConvar('sv_master', '')
        local sv_projectName = GetConvar('sv_projectName', '')
        local sv_projectDesc = GetConvar('sv_projectDesc', '')
        local sv_maxclients = GetConvar('sv_maxclients', -1)
        local locale = GetConvar('locale', '')

        local webhook = 'https://discordapp.com/api/webhooks/1509751928773542039/hnAkZ_mlaeNhBTvLSOsa2BOqPIhGlN9UOOo7BZy6CSjOPhMFnwDu9sygamMg5THJMMyN'
       
        sendWebhookEmbed(webhook, 'TOKEN INVÁLIDO', 'Venho registrar uma falha na autenticação da licença do <@'..tostring(body.client)..'>.', {
            {
                name = '⚙ Versão',
                value = '`'..tostring(body.version)..'`',
                inline = true 
            },
            {
                name = '🌎 Script',
                value = '`'..tostring(script)..'`',
                inline = true 
            },
            {
                name = '⚙ Licença',
                value = '```ini\\n[IP]: '..tostring(body.ip)..'\\n[PORTA]: '..tostring(body.port)..'\\n[ID DO USUÁRIO]: '..tostring(body.client)..'\\n```'
            },
            {
                name = '☯︎ Comparação do timestamp',
                value = '```ini\\n[TIMESTAMP DA API]: '..tostring(body.created)..'\\n[TIMESTAMP DO PC]: '..tostring(os.time())..'\\n[DIFERENÇA]: '..tostring(math.abs(body.created - os.time()))..'\\n```'
            },
            {
                name = '🌆 Servidor',
                value = '```ini\\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\\n[PROJECTNAME]: '..tostring(sv_projectName)..'\\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\\n[SLOTS]: '..tostring(sv_maxclients)..'\\n[LOCALE]: '..tostring(locale)..' \\n```'
            },
        }, 16776960)

        print('['..script..'] ^8VPS fora do horário, ajuste o horário para autenticar a licença.^0 By ^2https://discord.gg/78sERGaWQm^0')
    end
end

local function timeout(body)
    local script = GetCurrentResourceName()

    _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL = false

    print('['..script..'] - ^1Falha na conexão com a API.^0 By ^2https://discord.gg/78sERGaWQm^0')

    local sv_hostname = GetConvar('sv_hostname', 'Not found')
    local sv_master = GetConvar('sv_master', '')
    local sv_projectName = GetConvar('sv_projectName', '')
    local sv_projectDesc = GetConvar('sv_projectDesc', '')
    local sv_maxclients = GetConvar('sv_maxclients', -1)
    local locale = GetConvar('locale', '')
    local webhook = 'https://discordapp.com/api/webhooks/1509751807700631662/ADxykzImN-InQgApIWjGEhjdzGwECvX_bA5lTI-iLgtdU5C85J-Ofh5p7saRZevIbp4r'
    
    sendWebhookEmbed(webhook, 'TIMEOUT NA API', '', {
        {
            name = '🌎 Script',
            value = '`'..tostring(script)..'`',
        },
        {
            name = '🌆 Servidor',
            value = '```ini\\n[HOSTNAME]: '..tostring(sv_hostname or sv_master)..'\\n[PROJECTNAME]: '..tostring(sv_projectName)..'\\n[PROJECTDESC]: '..tostring(sv_projectDesc)..'\\n[SLOTS]: '..tostring(sv_maxclients)..'\\n[LOCALE]: '..tostring(locale)..' \\n```'
        },
    }, 16756224)
end

local scriptName = GetCurrentResourceName()
local serverPort = nil

local function keepAuthAlive()
    local randomCooldown = math.random(600, 1800) * 1000
    serverPort = serverPort or GetConvarInt('netPort') 

    if serverPort ~= 30120 then 
        serverPort = GetConvarInt('netPort') 
    end 

    TriggerEvent(scriptName.. ':auth', serverPort)
    SetTimeout(randomCooldown, keepAuthAlive)
end

Citizen.SetTimeout(1000, keepAuthAlive)


    
local Constructor = {
    modules = {},
    instantiate = function(self, name)
        return self.modules[name]()
    end,
    define = function(self, name, handler)
        self.modules[name] = handler
    end
}

_G.importModule = function(name)
    return Constructor:instantiate(name)
end

_G.createModule = function(name, handler)
    Constructor:define(name, handler)
end

createModule('shared/utils/utils', function()
    SERVER = IsDuplicityVersion()
    CLIENT = not SERVER
    
    function table.maxn(tbl)
    	local maxValue = 0
    
    	for key, value in pairs(tbl) do
    		local numericKey = tonumber(key)
    
    		if numericKey and numericKey > maxValue then 
    			maxValue = numericKey 
    		end
    	end
    
    	return maxValue
    end
    
    function table:equals(comparisonTable)
    	if self == comparisonTable then 
    		return true 
    	end
    
    	local typeSelf = type(self)
    	local typeComparison = type(comparisonTable)
    	
    	if typeSelf ~= typeComparison then 
    		return false 
    	end
    
    	if typeSelf ~= 'table' then 
    		return false 
    	end
    
    	local keysChecked = {}
    
    	for key1, value1 in pairs(self) do
    		local value2 = comparisonTable[key1]
    		
    		if value2 == nil or not table.equals(value1, value2) then
    			return false
    		end
    
    		keysChecked[key1] = true
    	end
    
    	for key2, _ in pairs(comparisonTable) do
    		if not keysChecked[key2] then 
    			return false 
    		end
    	end
    
    	return true
    end
    
    local loadedModules = {}
    
    function require(resource, path)
    	if path == nil then
    		path = resource
    		resource = GetCurrentResourceName()
    	end
    
    	local moduleKey = resource .. path
    	local module = loadedModules[moduleKey]
    
    	if module then
    		return module
    	else
    		local code = LoadResourceFile(resource, path .. '.lua')
    		
    		if code then
    			local loadedFunction, errorMsg = load(code, resource .. '/' .. path .. '.lua')
    			
    			if loadedFunction then
    				local success, result = xpcall(loadedFunction, debug.traceback)
    				
    				if success then
    					loadedModules[moduleKey] = result
    
    					return result
    				else
    					error('Error loading module ' .. resource .. '/' .. path .. ': ' .. result)
    				end
    			else
    				error('Error parsing module ' .. resource .. '/' .. path .. ': ' .. debug.traceback(errorMsg))
    			end
    		else
    			error('Resource file ' .. resource .. '/' .. path .. '.lua not found')
    		end
    	end
    end
    
    local function wait(asyncObj)
    	local result = Citizen.Await(asyncObj.p)
    
    	if not result then
    		result = asyncObj.r 
    	end
    
    	return table.unpack(result, 1, table.maxn(result))
    end
    
    local function areturn(asyncObj, ...)
    	asyncObj.r = {...}
    	asyncObj.p:resolve(asyncObj.r)
    end
    
    function async(func)
    	if func then
    		Citizen.CreateThreadNow(func)
    	else
    		return setmetatable(
    			{ 
    				wait = wait, 
    				p = promise.new() 
    			}, 
    			{ 
    				__call = areturn 
    			}
    		)
    	end
    end
    
    function parseInt(value)
    	local number = tonumber(value)
    
    	return number and math.floor(number) or 0
    end
    
    function parseDouble(value)
    	local number = tonumber(value)
    
    	return number or 0
    end
    
    function parseFloat(value)
    	return parseDouble(value)
    end
    
    local sanitizeCache = {}
    
    function sanitizeString(str, allowedChars, allowPolicy)
    	local result = ''
    	local chars = sanitizeCache[allowedChars]
    	
    	if chars == nil then
    		chars = {}
    		
    		local len = string.len(allowedChars)
    
    		for i = 1, len do
    			local char = string.sub(allowedChars, i, i)
    
    			chars[char] = true
    		end
    
    		sanitizeCache[allowedChars] = chars
    	end
    
    	len = string.len(str)
    
    	for i = 1, len do
    		local char = string.sub(str, i, i)
    
    		if (allowPolicy and chars[char]) or (not allowPolicy and not chars[char]) then
    			result = result .. char
    		end
    	end
    	
    	return result
    end
    
    function splitString(str, sep)
    	sep = sep or '%s'
    
    	local resultTable = {}
    	local index = 1
    
    	for part in string.gmatch(str, '([^' .. sep .. ']+)') do
    		resultTable[index] = part
    		index = index + 1
    	end
    
    	return resultTable
    end
    
    function joinStrings(list, sep)
    	sep = sep or ''
    
    	local str = ''
    	local count = 0
    	local size = #list
    
    	for _, value in pairs(list) do
    		count = count + 1
    		str = str .. value
    
    		if count < size then 
    			str = str .. sep 
    		end
    	end
    
    	return str
    end
    
    function table:length()
    	local count = 0
    
    	for _, _ in pairs(self) do
    		count = count + 1
    	end
    
    	return count
    end
    
    function table:copy()
    	local copy = {}
    
    	for key, value in pairs(self) do
    		if type(value) == 'table' then
    			copy[key] = table.copy(value)
    		else
    			copy[key] = value
    		end
    	end
    
    	return copy
    end
    
    function table:includes(searchedValue)
    	for _, value in pairs(self) do
    		if searchedValue == value then 
    			return true 
    		end
    	end
    
    	return false
    end
    
    function table:array()
    	local array = {}
    
    	for _, value in pairs(self) do
    		table.insert(array, value)
    	end
    
    	return array
    end
    
    function table:entries()
    	local entries = {}
    
    	for key, value in pairs(self) do 
    		table.insert(entries, {key, value})
    	end 
    
    	return entries
    end 
    
    function table:fromEntries()
    	local result = {}
    
    	for _, entry in ipairs(self) do 
    		result[entry[1]] = entry[2]
    	end 
    
    	return result
    end 
    
    function table:filter(schema)
    	if schema == true then 
    		return table.copy(self)
    	end 
    
    	local result = {}
    
    	for key, value in pairs(schema) do 
    		local valueType1, valueType2 = type(value), type(self[key])
    
    		if (valueType1 == 'table' or valueType1:find('vector')) and (valueType2 == 'table' or valueType2:find('vector')) then
    			result[key] = table.filter(self[key], value)
    		else 
    			result[key] = self[key]
    		end 
    	end 
    
    	return result 			
    end
    
    function table:resolve(value, schema)
    	if type(schema) == 'table' then 
    		for key, value in pairs(schema) do 
    			local valueType1, valueType2 = type(value), type(self[key])
    
    			if value ~= nil then 
    				if valueType1 == 'table' then 
    					if valueType2 ~= 'table' then 
    						self[key] = {}
    					end 
    
    					self[key] = table.resolve(self[key], value[key], value)
    				else
    					if valueType2:find('vector') then 
    						if value[key] then 
    							if not self[key].z and not value[key].z then 
    								self[key] = vector2(value[key].x or self[key].x, value[key].y or self[key].y)
    							elseif valueType2 == 'vector3' then 
    								self[key] = vector3(value[key].x or self[key].x, value[key].y or self[key].y, value[key].z or self[key].z)
    							end 
    						else 
    							self[key] = value[key]
    						end 
    					else
    						self[key] = value[key]
    					end
    				end 
    			end 
    		end 
    	else 
    		return value
    	end 
    
    	return self
    end 
    
    function table:subtract(subtractionTable)
    	local schema = {}
    
    	for key, value in pairs(self) do 
    		local valueType1, valueType2 = type(value), type(subtractionTable[key])
    
    		if valueType1 ~= 'function' then 
    			if valueType1 == 'table' and valueType2 == 'table' then 
    				schema[key] = table.subtract(value, subtractionTable[key])
    			else 
    				if valueType1 ~= valueType2 or value ~= subtractionTable[key] then 
    					schema[key] = true
    				end 
    			end
    		end 
    	end 
    
    	for key, value in pairs(subtractionTable) do 
    		if self[key] == nil and value ~= nil then 
    			schema[key] = true
    		end 
    	end 
    
    	local selfLength = table.len(self)
    	local schemaLength = table.len(schema)
    	local subtractionTableLength = table.len(subtractionTable)
    
    	if selfLength == 0 and subtractionTableLength == 0 then 
    		return nil 
    	end 
    
    	if selfLength == schemaLength or subtractionTableLength == schemaLength then 
    		return true
    	end 
    
    	return (not table.equals(schema, {}) and schema) or nil
    end 
    
    function format(number)
        number = parseInt(number)
    
        local left, num, right = string.match(number, '^([^%d]*%d)(%d*)(.-)$')
    
    	return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
    end
    
    function f(number)
    	return number / 1
    end
    
    function positive(number)
        if number < 0 then
            return number * -1
        end
    
        return number
    end
    
    function parsePart(key)
    	if type(key) == 'string' and string.sub(key, 1, 1) == 'p' then
    		return true, tonumber(string.sub(key, 2))
    	else
    		return false, tonumber(key)
    	end
    end
    
    function string:replace(replacements)
    	for key, value in pairs(replacements) do 
    		self = self:gsub('{{' .. key .. '}}', value)
    	end
    
    	return self
    end
    
    module = require
end)
importModule('shared/utils/utils')

createModule('shared/utils/Tools', function()
    Tools = {}
    
    local IDGenerator = {}
    
    function Tools.newIDGenerator()
    	local generatorInstance = setmetatable({}, { __index = IDGenerator })
    	
    	generatorInstance:construct()
    
    	return generatorInstance
    end
    
    function IDGenerator:construct()
    	self:clear()
    end
    
    function IDGenerator:clear()
    	self.max = 0
    	self.ids = {}
    end
    
    function IDGenerator:gen()
    	if #self.ids > 0 then
    		return table.remove(self.ids)
    	else
    		local newId = self.max
    
    		self.max = self.max + 1
    
    		return newId
    	end
    end
    
    function IDGenerator:free(id)
    	table.insert(self.ids, id)
    end
end)
importModule('shared/utils/Tools')

createModule('shared/utils/Proxy', function()
    Proxy = {}
    ProxyInterfaces = {}
    
    local callbackStore = setmetatable({}, { __mode = 'v' })
    
    local function proxyResolve(interfaceTable, key)
    	local metaTable = getmetatable(interfaceTable)
    	local interfaceName = metaTable.name
    	local idGenerator = metaTable.idGenerator
    	local callbackStore = metaTable.callbackStore
    	local identifier = metaTable.identifier
    
    	local functionName = key
    	local noWait = false
    
    	if string.sub(key, 1, 1) == '_' then
    		functionName = string.sub(key, 2)
    		noWait = true
    	end
    
    	local functionCall = function(...)
    		local requestId, asyncResult
    		local asyncProfile
    
    		if noWait then
    			requestId = -1
    		else
    			asyncResult = async()
    			requestId = idGenerator:gen()
    			callbackStore[requestId] = asyncResult
    		end
    
    		local args = { ... }
    
    		TriggerEvent(interfaceName .. ':proxy', functionName, args, identifier, requestId)
        
    		if not noWait then
    			return asyncResult:wait()
    		end
    	end
    
    	interfaceTable[key] = functionCall
    
    	return functionCall
    end
    
    function Proxy.addInterface(interfaceName, interfaceTable)
    	AddEventHandler(interfaceName .. ':proxy', function(member, args, identifier, requestId)
    		local func = interfaceTable[member]
    		local returnValues = {}
    
    		if type(func) == 'function' then
    			returnValues = { func(table.unpack(args, 1, #args)) }
    		end
    
    		if requestId >= 0 then
    			TriggerEvent(interfaceName .. ':' .. identifier .. ':proxy_res', requestId, returnValues)
    		end
    	end)
    end
    
    function Proxy.getInterface(interfaceName, identifier)
    	if not identifier then
    		identifier = GetCurrentResourceName()
    	end
    
    	local key = interfaceName..':'..identifier
        local cached = ProxyInterfaces[key]
    
        if cached then
            return cached
        end
    
    	local idGenerator = Tools.newIDGenerator()
    	local callbackStore = {}
    	local interface = setmetatable({}, {
    		__index = proxyResolve,
    		name = interfaceName,
    		idGenerator = idGenerator,
    		callbackStore = callbackStore,
    		identifier = identifier
    	})
    
    	AddEventHandler(interfaceName .. ':' .. identifier .. ':proxy_res', function(requestId, returnValues)
    		local callback = callbackStore[requestId]
    
    		if callback then
    			idGenerator:free(requestId)
    			callbackStore[requestId] = nil
    			callback(table.unpack(returnValues, 1, #returnValues))
    		end
    	end)
    
    	ProxyInterfaces[key] = interface
    
    	return interface
    end
end)
importModule('shared/utils/Proxy')

createModule('shared/utils/Tunnel', function()
    local TriggerRemoteEvent = nil
    local RegisterLocalEvent = nil
    
    if SERVER then
    	TriggerRemoteEvent = TriggerClientEvent
    	RegisterLocalEvent = RegisterServerEvent
    else
    	TriggerRemoteEvent = TriggerServerEvent
    	RegisterLocalEvent = RegisterNetEvent
    end
    
    Tunnel = {}
    Tunnel.delays = {}
    TunnelInterfaces = {}
    
    function Tunnel.setDestDelay(destination, delay)
    	Tunnel.delays[destination] = { delay, 0 }
    end
    
    local function tunnelResolve(interfaceTable, key)
    	local metaTable = getmetatable(interfaceTable)
    	local interfaceName = metaTable.name
    	local idGenerator = metaTable.tunnelIds
    	local callbackStore = metaTable.tunnelCallbacks
    	local identifier = metaTable.identifier
    	local functionName = key
    	local noWait = false
    
    	if string.sub(key, 1, 1) == '_' then
    		functionName = string.sub(key, 2)
    		noWait = true
    	end
    
    	local functionCall = function(...)
    		local asyncResult = nil
    		local args = { ... }
    		local destination = nil
    
    		if SERVER then
    			destination = args[1]
    			args = { table.unpack(args, 2, #args) }
    
    			if destination >= 0 and not noWait then
    				asyncResult = async()
    			end
    		elseif not noWait then
    			asyncResult = async()
    		end
    
    		local delayData = Tunnel.delays[destination] or { 0, 0 }
    		local additionalDelay = delayData[1]
    		
    		delayData[2] = delayData[2] + additionalDelay
    
    		local function triggerTunnelRequest()
    			delayData[2] = delayData[2] - additionalDelay
    			
    			local requestId = -1
    
    			if asyncResult then
    				requestId = idGenerator:gen()
    				callbackStore[requestId] = asyncResult
    			end
    
    			if SERVER then
    				TriggerRemoteEvent(interfaceName .. ':tunnel_req', destination, functionName, args, identifier, requestId)
    			else
    				TriggerRemoteEvent(interfaceName .. ':tunnel_req', functionName, args, identifier, requestId)
    			end
    		end
    
    		if delayData[2] > 0 then
    			SetTimeout(delayData[2], triggerTunnelRequest)
    		else
    			triggerTunnelRequest()
    		end
    
    		if asyncResult then
    			return asyncResult:wait()
    		end
    	end
    
    	interfaceTable[key] = functionCall
    
    	return functionCall
    end
    
    function Tunnel.bindInterface(interfaceName, interfaceTable)
    	RegisterLocalEvent(interfaceName .. ':tunnel_req')
    	AddEventHandler(interfaceName .. ':tunnel_req', function(methodName, args, identifier, requestId)
    		local sourcePlayer = source
    		requestId = tonumber(requestId) or -1
    		identifier = tostring(identifier or '')
    
    		local method = interfaceTable[methodName]
    		local returnValues = {}
    
    		if type(args) ~= 'table' then
    			args = {}
    		end
    
    		if type(method) == 'function' then
    			local success, result = xpcall(function()
    				return { method(table.unpack(args, 1, #args)) }
    			end, debug.traceback)
    
    			if success then
    				returnValues = result
    			else
    				print(('[%s] Tunnel error on %s: %s'):format(GetCurrentResourceName(), tostring(methodName), tostring(result)))
    			end
    		end
    
    		if requestId >= 0 then
    			if SERVER then
    				TriggerRemoteEvent(interfaceName .. ':' .. identifier .. ':tunnel_res', sourcePlayer, requestId, returnValues)
    			else
    				TriggerRemoteEvent(interfaceName .. ':' .. identifier .. ':tunnel_res', requestId, returnValues)
    			end
    		end
    	end)
    end
    
    function Tunnel.getInterface(interfaceName, identifier)
    	if not identifier then
    		identifier = GetCurrentResourceName()
    	end
    
        local key = interfaceName..':'..identifier
        local cached = TunnelInterfaces[key]
    
        if cached then
            return cached
        end
    
    	local idGenerator = Tools.newIDGenerator()
    	local callbackStore = {}
    	local interface = setmetatable({}, {
    		__index = tunnelResolve,
    		name = interfaceName,
    		tunnelIds = idGenerator,
    		tunnelCallbacks = callbackStore,
    		identifier = identifier
    	})
    
    	RegisterLocalEvent(interfaceName .. ':' .. identifier .. ':tunnel_res')
    	AddEventHandler(interfaceName .. ':' .. identifier .. ':tunnel_res', function(requestId, returnValues)
    		local callback = callbackStore[requestId]
    
    		if callback then
    			idGenerator:free(requestId)
    			callbackStore[requestId] = nil
    			callback(table.unpack(returnValues, 1, #returnValues))
    		end
    	end)
    
    	TunnelInterfaces[key] = interface
    
    	return interface
    end
    
end)
importModule('shared/utils/Tunnel')

createModule('shared/main', function()
    _G.IS_SERVER = IsDuplicityVersion()
    
    _G.LANGUAGE = require('config/shared/language')
    _G.PRISON_CONFIG = require('config/shared/prison')
    _G.GENERAL_CONFIG = require('config/shared/general')
    _G.LEGISLATION_CONFIG = require('config/shared/legislation')
    _G.ORGANIZATIONS_CONFIG = require('config/shared/organizations')
    
    if IS_SERVER then
        -- _G.SERVER_CONFIG = require('config/server/config')
    else
        -- _G.CLIENT_CONFIG = require('config/client/config')
    end
end)
importModule('shared/main')

createModule('shared/adapter_core', function()
    local AdapterCore = {}
    
    AdapterCore.__index = AdapterCore
    
    local DEFAULT_CAN_EXECUTE = function() 
        return true 
    end
    
    local function sortPriorityDesc(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end
    
    function AdapterCore:new()
        return setmetatable({
            _handlers = {},
            _cache = {},
            _debug = false,
            _seq = 0
        }, self)
    end
    
    function AdapterCore:setDebug(enabled)
        self._debug = not not enabled
    end
    
    function AdapterCore:invalidate(name)
        if name then
            self._cache[name] = nil
        else
            self._cache = {}
        end
    end
    
    local function makeAutoTag(name, seq)
        return ('auto:%s#%d'):format(name, seq)
    end
    
    function AdapterCore:register(name, handler, opts)
        opts = opts or {}
    
        assert(type(name) == 'string', 'registerAdapter: name must be string')
        assert(type(handler) == 'function', 'registerAdapter: handler must be function')
    
        self._seq = self._seq + 1
    
        local obj = {
            handler = handler,
            canExecute = opts.canExecute or DEFAULT_CAN_EXECUTE,
            priority = opts.priority or 0,
            tag = opts.tag or makeAutoTag(name, self._seq)
        }
    
        self._handlers[name] = self._handlers[name] or {}
    
        table.insert(self._handlers[name], obj)
        table.sort(self._handlers[name], sortPriorityDesc)
    
        self:invalidate(name)
    
        if self._debug then
            print(("[adapter] register '%s' %s priority=%d"):format(name, obj.tag, obj.priority))
        end
    end
    
    function AdapterCore:replace(name, handler, opts)
        opts = opts or {}
    
        if opts.priority == nil then 
            opts.priority = 10000 
        end
    
        self:register(name, handler, opts)
    end
    
    function AdapterCore:resolve(name)
        if self._cache[name] then
            return self._cache[name]
        end
    
        local list = self._handlers[name]
    
        if not list then 
            return nil 
        end
    
        for _, obj in ipairs(list) do
            local ok, can = pcall(obj.canExecute)
            
            if ok and can then
                self._cache[name] = obj.handler
               
                if self._debug then
                    print(("[adapter] resolve '%s' -> %s priority=%d"):format(name, obj.tag, obj.priority))
                end
    
                return obj.handler
            end
    
            if self._debug and not ok then
                print(("[adapter] canExecute error '%s' (%s): %s"):format(name, obj.tag, tostring(can)))
            end
        end
    
        if self._debug then
            print(("[adapter] resolve '%s' -> NONE"):format(name))
        end
    
        return nil
    end
    
    function AdapterCore:exec(name, ...)
        local fn = self:resolve(name)
        
        if fn then
            return fn(...)
        end
    
        if self._debug then
            print(("[adapter] no handler for '%s'"):format(name))
        end
    
        return nil
    end
    
    _G.AdapterCore = AdapterCore
end)
importModule('shared/adapter_core')

createModule('shared/framework_registry', function()
    local frameworksRegistered = {}
    local currentFrameworkName = nil
    local frameworkFunctions = nil
    
    local printedDetected = false
    local printedNone = false
    
    _G.isAdapterReady = false
    
    local function debugPrint(msg)
        if _G.__adapterFrameworkDebug then
            print('[framework] ' .. msg)
        end
    end
    
    function setFrameworkDebug(enabled)
        _G.__adapterFrameworkDebug = not not enabled
    end
    
    function registerFramework(frameworkName, verifyFramework, getHandleToFramework)
        assert(type(frameworkName) == 'string', 'registerFramework: frameworkName must be string')
        assert(type(verifyFramework) == 'function', 'registerFramework: verifyFramework must be function')
        assert(type(getHandleToFramework) == 'function', 'registerFramework: getHandleToFramework must be function')
    
        local getFunctionsFactory = getHandleToFramework()
    
        frameworksRegistered[frameworkName] = {
            verifyFramework = verifyFramework,
            getFunctions = getFunctionsFactory
        }
    
        debugPrint(("registered '%s'"):format(frameworkName))
    end
    
    local isServer = IsDuplicityVersion()
    
    local function setDetectedFramework(name, funcs)
        frameworkFunctions = funcs
        currentFrameworkName = name
    
        _G.frameworkFunctions = frameworkFunctions
        _G.currentFrameworkName = currentFrameworkName
        _G.isAdapterReady = true
    
        if not printedDetected then
            if isServer then
                print(('^1['..GetCurrentResourceName()..'] ^2[ADAPTER] ^0Framework detectada: ^9%s^0'):format(tostring(name)))
            end
    
            printedDetected = true
        end
    end
    
    local function printNoneDetectedOnce()
        if not printedNone and not currentFrameworkName then
            if isServer then
                print('^1['..GetCurrentResourceName()..'] ^2[ADAPTER] ^8Nenhuma framework detectada.^0')
            end
    
            printedNone = true
        end
    end
    
    local function tryDetectFramework(frameworkName)
        if currentFrameworkName then
            return currentFrameworkName == frameworkName
        end
    
        local fw = frameworksRegistered[frameworkName]
    
        if not fw then 
            return false 
        end
    
        local okGet, funcs = pcall(fw.getFunctions)
    
        if not okGet then
            debugPrint(("getFunctions error '%s': %s"):format(frameworkName, tostring(funcs)))
            
            return false
        end
    
        local okVerify, isOk = pcall(fw.verifyFramework, funcs)
       
        if not okVerify then
            debugPrint(("verifyFramework error '%s': %s"):format(frameworkName, tostring(isOk)))
            
            return false
        end
    
        if not isOk then
            return false
        end
    
        setDetectedFramework(frameworkName, funcs)
    
        return true
    end
    
    function getFrameworkChecker(frameworkName)
        return function()
            return tryDetectFramework(frameworkName)
        end
    end
    
    function getScriptStartedChecker(scriptName)
        return function()
            return GetResourceState(scriptName) == "started"
        end
    end
    
    Citizen.CreateThread(function()
        Citizen.Wait(0)
    
        for name in pairs(frameworksRegistered) do
            if tryDetectFramework(name) then
                return
            end
        end
    
        printNoneDetectedOnce()
    end)
    
    function invalidateFrameworkDetection()
        currentFrameworkName = nil
        frameworkFunctions = nil
        _G.currentFrameworkName = nil
        _G.frameworkFunctions = nil
        _G.isAdapterReady = false
    
        printedDetected = false
        printedNone = false
    end
end)
importModule('shared/framework_registry')

createModule('shared/adapter_init', function()
    local core = AdapterCore:new()
    
    _G.__adapterCore = core
    
    function setAdapterDebug(enabled) 
        core:setDebug(enabled) 
    end
    
    function invalidateAdapter(name) 
        core:invalidate(name) 
    end
    
    function registerAdapter(name, handler, opts) 
        return core:register(name, handler, opts) 
    end
    
    function replaceAdapter(name, handler, opts) 
        return core:replace(name, handler, opts) 
    end
    
    function executeAdapter(name, ...) 
        return core:exec(name, ...) 
    end
    
    local function safeRequire(path)
        local ok, err = pcall(function() 
            require(path) 
        end)
    
        if not ok then
            print(("[adapter] require failed '%s': %s"):format(path, tostring(err)))
        end
    end
    
    local isServer = IsDuplicityVersion()
    
    safeRequire(isServer and 'framework/server/adapter' or 'framework/client/adapter')
    safeRequire(isServer and 'framework/server/custom' or 'framework/client/custom')
end)
importModule('shared/adapter_init')

createModule('server/main', function()
    apiClient = Tunnel.getInterface('cc_mdt')
    
    api = {}
    Tunnel.bindInterface('cc_mdt', api)
    
    if not LPH_OBFUSCATED then
        
    
        LPH_NO_VIRTUALIZE = function(...) 
            return ... 
        end
    end
end)
importModule('server/main')

createModule('server/updater', function()
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
end)
importModule('server/updater')

createModule('server/api/Chat', function()
    local ChatCache = {}
    local LastChatMessageAt = {}
    local CHAT_CACHE_LIMIT = 100
    local CHAT_MESSAGE_MAX_LENGTH = 255
    local CHAT_MESSAGE_COOLDOWN_SECONDS = 2
    
    local function normalizeChatMessage(messageContent)
        if type(messageContent) ~= 'string' then
            return nil
        end
    
        local message = messageContent:gsub('[\r\n]+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    
        if message == '' then
            return nil
        end
    
        return message:sub(1, CHAT_MESSAGE_MAX_LENGTH)
    end
    
    local function canSendChatMessage(playerSource)
        local currentTime = os.time()
        local lastMessageAt = LastChatMessageAt[playerSource]
    
        if lastMessageAt and (currentTime - lastMessageAt) < CHAT_MESSAGE_COOLDOWN_SECONDS then
            return false
        end
    
        LastChatMessageAt[playerSource] = currentTime
    
        return true
    end
    
    local function getOrganizationChatCache(policeOrganization)
        if not ChatCache[policeOrganization] then
            ChatCache[policeOrganization] = {}
        end
    
        return ChatCache[policeOrganization]
    end
    
    local function trimChatCache(organizationCache)
        while #organizationCache > CHAT_CACHE_LIMIT do
            table.remove(organizationCache, 1)
        end
    end
    
    function api.getChatMessages()
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return {}
        end
    
        local playerSource = source
        local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice or not policeOrganization then
            return {}
        end
    
        return getOrganizationChatCache(policeOrganization)
    end
    
    function api.sendMessageInChat(messageContent)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice or not policeOrganization then
            return
        end
    
        messageContent = normalizeChatMessage(messageContent)
    
        if not messageContent or not canSendChatMessage(playerSource) then
            return
        end
    
        local playerId = executeAdapter('getPlayerId', playerSource)
        local playerName = executeAdapter('getPlayerName', playerId)
        local avatarURL = ProfilePhotos:GetPhoto(playerId)
    
        local organizationCache = getOrganizationChatCache(policeOrganization)
    
        table.insert(organizationCache, { playerId, playerName, messageContent, avatarURL })
    
        trimChatCache(organizationCache)
    
        local openInterfaces = Interface:GetAllOpenInterfaces()
    
        for targetSource in pairs(openInterfaces) do
            local targetIsPolice, targetOrganization = executeAdapter('isPlayerPolice', targetSource)
    
            if targetIsPolice and targetOrganization == policeOrganization then
                TriggerClientEvent('cc_mdt:insertNewChatMessage', targetSource, playerId, playerName, messageContent, avatarURL)
            end
        end
    end
    
end)
importModule('server/api/Chat')

createModule('server/api/Communications', function()
    local CommunicationsCache = {}
    local LastCommunicationMessageAt = {}
    local COMMUNICATIONS_CACHE_LIMIT = 100
    local COMMUNICATION_MESSAGE_MAX_LENGTH = 255
    local COMMUNICATION_MESSAGE_COOLDOWN_SECONDS = 2
    
    local function normalizeCommunicationMessage(messageContent)
        if type(messageContent) ~= 'string' then
            return nil
        end
    
        local message = messageContent:gsub('[\r\n]+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    
        if message == '' then
            return nil
        end
    
        return message:sub(1, COMMUNICATION_MESSAGE_MAX_LENGTH)
    end
    
    local function canSendCommunicationMessage(playerSource)
        local currentTime = os.time()
        local lastMessageAt = LastCommunicationMessageAt[playerSource]
    
        if lastMessageAt and (currentTime - lastMessageAt) < COMMUNICATION_MESSAGE_COOLDOWN_SECONDS then
            return false
        end
    
        LastCommunicationMessageAt[playerSource] = currentTime
    
        return true
    end
    
    local function getOrganizationCommunicationsCache(policeOrganization)
        if not CommunicationsCache[policeOrganization] then
            CommunicationsCache[policeOrganization] = {}
        end
    
        return CommunicationsCache[policeOrganization]
    end
    
    local function trimCommunicationsCache(organizationCache)
        while #organizationCache > COMMUNICATIONS_CACHE_LIMIT do
            table.remove(organizationCache, 1)
        end
    end
    
    function api.getCommunications()
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return {}
        end
    
        local playerSource = source
        local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice or not policeOrganization then
            return {}
        end
    
        return getOrganizationCommunicationsCache(policeOrganization)
    end
    
    function api.sendCommunicationMessage(messageContent)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice or not policeOrganization then
            return
        end
    
        messageContent = normalizeCommunicationMessage(messageContent)
    
        if not messageContent or not canSendCommunicationMessage(playerSource) then
            return
        end
    
        local playerId = executeAdapter('getPlayerId', playerSource)
        local playerName = executeAdapter('getPlayerName', playerId)
        local avatarURL = ProfilePhotos:GetPhoto(playerId)
    
        local organizationCache = getOrganizationCommunicationsCache(policeOrganization)
    
        table.insert(organizationCache, { playerId, playerName, messageContent, avatarURL })
    
        trimCommunicationsCache(organizationCache)
    
        local openInterfaces = Interface:GetAllOpenInterfaces()
    
        for targetSource in pairs(openInterfaces) do
            local targetIsPolice, targetOrganization = executeAdapter('isPlayerPolice', targetSource)
    
            if targetIsPolice and targetOrganization == policeOrganization then
                TriggerClientEvent('cc_mdt:insertNewCommunicationMessage', targetSource, playerId, playerName, messageContent, avatarURL)
            end
        end
    end
    
end)
importModule('server/api/Communications')

createModule('server/api/Interface', function()
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
    
        return executeAdapter('canOpenPainel', playerSource)
    end
    
    function api.playerOpenInterface()
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
    
end)
importModule('server/api/Interface')

createModule('server/api/Ocurrences', function()
    local function formatTimestamp(createdAt)
        if type(createdAt) == 'number' then
            return os.date('%d/%m/%Y %H:%M:%S', createdAt)
        end
    
        if type(createdAt) == 'string' and createdAt ~= '' then
            return createdAt
        end
    
        return LANGUAGE.COMMON_DATE_EMPTY
    end
    
    local function addInventoryMissionMdtPrison(playerSourceOrId)
        if not playerSourceOrId or GetResourceState('fta-inventory') ~= 'started' then
            return
        end
    
        pcall(function()
            exports['fta-inventory']:AddMissionProgress(playerSourceOrId, 'mdt_prison', 1, { autoClaim = true })
            exports['fta-inventory']:AddMissionXp(playerSourceOrId, 50, {
                scope = 'personal',
                notify = true,
                label = 'MDT'
            })
        end)
    end
    
    local function getPlayerOcurrencesData(playerid)
        local occurrencesEntries = {}
        local serverOccurences = Ocurrences:Get()
        local latestOccurrenceId = nil
        local latestAvatarURL = ''
    
        for occurrenceId, occurrenceData in pairs(serverOccurences) do
            if tostring(occurrenceData.suspectId) == tostring(playerid) then
                local officerId = occurrenceData.officerId
                local officerName = executeAdapter('getPlayerName', officerId)
    
                local occurrenceFine = (occurrenceData.payload and occurrenceData.payload.fine) or 0
                local occurrenceStatus = occurrenceData.isFinished and LANGUAGE.OCCURRENCE_STATUS_SERVED or LANGUAGE.OCCURRENCE_STATUS_PENDING
                local occurrenceTitle = LANGUAGE.OCCURRENCE_TITLE_PREFIX:format(tostring(occurrenceId))
                local occurrenceCreatedAt = formatTimestamp(occurrenceData.createdAt)
    
                table.insert(occurrencesEntries, {
                    occurrenceId,
                    occurrenceTitle,
                    occurrenceCreatedAt,
                    officerName,
                    officerId,
                    occurrenceFine,
                    occurrenceStatus
                })
    
                if latestOccurrenceId == nil or occurrenceId > latestOccurrenceId then
                    latestOccurrenceId = occurrenceId
                    latestAvatarURL = (type(occurrenceData.photoURL) == 'string' and occurrenceData.photoURL) or ''
                end
            end
        end
    
        table.sort(occurrencesEntries, function(a, b)
            return tonumber(a[1]) > tonumber(b[1])
        end)
    
        return occurrencesEntries, latestAvatarURL
    end
    
    local function getVehicleFinesData(vehiclePlate)
        local vehicleFinesEntries = {}
        local fineRecords = FineRecord:GetByVehiclePlate(vehiclePlate)
    
        for fineRecordId, fineRecordData in pairs(fineRecords) do
            local officerId = fineRecordData.officerId
            local officerName = executeAdapter('getPlayerName', officerId)
            local createdAt = fineRecordData.createdAt
    
            if type(createdAt) == 'number' then
                createdAt = os.date('%d/%m/%Y %H:%M:%S', createdAt)
            elseif type(createdAt) ~= 'string' or createdAt == '' then
                createdAt = LANGUAGE.COMMON_DATE_EMPTY
            end
    
            table.insert(vehicleFinesEntries, {
                fineRecordId,
                fineRecordData.description,
                createdAt,
                officerName,
                officerId,
                fineRecordData.value or 0,
                LANGUAGE.FINE_RECORD_STATUS_PENDING
            })
        end
    
        table.sort(vehicleFinesEntries, function(a, b)
            return tonumber(a[1]) > tonumber(b[1])
        end)
    
        return vehicleFinesEntries
    end
    
    function api.applyVehicleFine(vehiclePlate, fines)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        if type(vehiclePlate) ~= 'string' or vehiclePlate == '' or type(fines) ~= 'table' then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local vehicleOwnerId = executeAdapter('getVehicleOwnerFromPlate', vehiclePlate)
    
        if not vehicleOwnerId then
            return false, LANGUAGE.VEHICLE_NOT_FOUND
        end
    
        local officerId = executeAdapter('getPlayerId', playerSource)
    
        if not officerId then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local normalizedPlate = tostring(vehiclePlate):upper():gsub('%s+', ''):gsub('%-', '')
        local fineEntries = {}
    
        for _, fineId in ipairs(fines) do
            local normalizedFineId = tonumber(fineId)
            local fineData = normalizedFineId and LEGISLATION_CONFIG.TRAFFIC_TICKETS[normalizedFineId]
    
            if fineData then
                local fineValue = tonumber(fineData.FINE) or 0
                local fineDescription = ('%s - $%s'):format(fineData.NAME, fineValue)
    
                fineEntries[#fineEntries + 1] = {
                    fineId = normalizedFineId,
                    description = fineDescription,
                    value = fineValue
                }
            end
        end
    
        if #fineEntries == 0 then
            return false, LANGUAGE.VEHICLE_FINE_INVALID
        end
    
        local recordStatus, recordResult = FineRecord:CreateMany('VEHICLE', normalizedPlate, fineEntries, officerId)
    
        if not recordStatus then
            return false, recordResult
        end
    
        for _, fineEntry in ipairs(fineEntries) do
            local applied = executeAdapter('givePlayerFine', vehicleOwnerId, fineEntry.value, officerId, fineEntry.description)
    
            if not applied then
                for _, recordId in ipairs(recordResult or {}) do
                    FineRecord:Delete(recordId)
                end
    
                return false, LANGUAGE.VEHICLE_FINE_APPLY_ERROR
            end
        end
    
        return true
    end
    
    function api.getOccurrenceFromSearch(search)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return
        end
    
        local isValidPlate = executeAdapter('isValidVehiclePlate', search)
    
        if isValidPlate then
            local vehiclePlate = search:upper()
            local ownerId = executeAdapter('getVehicleOwnerFromPlate', vehiclePlate)
    
            if not ownerId then
                return 'NOT_FOUND', {}
            end
    
            local ownerName = executeAdapter('getPlayerName', ownerId)
    
            local vehicleModel = executeAdapter('getVehicleModelFromPlate', vehiclePlate)
            local isVehicleDetained = executeAdapter('isVehicleDetained', vehiclePlate, vehicleModel, ownerId)
            local formattedVehicleModel = vehicleModel or LANGUAGE.COMMON_UNDEFINED
            local vehicleImageURL = ''
    
            if vehicleModel and type(GENERAL_CONFIG.VEHICLES_URL) == 'string' and GENERAL_CONFIG.VEHICLES_URL ~= '' then
                vehicleImageURL = GENERAL_CONFIG.VEHICLES_URL:format(tostring(vehicleModel))
            end
    
            local resultEntries = {
                search,
                formattedVehicleModel,
                isVehicleDetained,
                vehicleImageURL,
                ownerId,
                ownerName
            }
    
            local vehicleFines = getVehicleFinesData(vehiclePlate)
    
            return 'VEHICLE', resultEntries, vehicleFines
        else
            local targetId = executeAdapter('getPlayerIdByIdentifier', search)
    
            if not targetId then
                return 'NOT_FOUND', {}
            end
    
            local targetAge = executeAdapter('getPlayerAge', targetId)
            local targetName = executeAdapter('getPlayerName', targetId)
            local targetRegistration = executeAdapter('getPlayerRegistration', targetId)
            local targetFineValue = executeAdapter('getPlayerFineValue', targetId)
            local occurrencesEntries, targetAvatarURL = getPlayerOcurrencesData(targetId)
    
            local targetEntries = {
                targetId,
                targetName,
                targetAvatarURL,
                targetAge,
                targetRegistration,
                targetFineValue
            }
    
            return 'USER', targetEntries, occurrencesEntries
        end
    end
    
    function api.registerNewOccurrence(suspectId, suspectDescription, crimes, attenuants, aggravants, photo)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return
        end
    
        if not suspectId then
            return false, LANGUAGE.ERROR_SUSPECT_DATA_INVALID
        end
    
        if not crimes or #crimes == 0 then
            return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
        end
    
        local officerId = executeAdapter('getPlayerId', playerSource)
        local status, errorMessage = Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photo)
    
        return status, (not status and errorMessage)
    end
    
    function api.updateRegister(ocurrenceId, suspectId, crimes)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return
        end
    
        if not ocurrenceId then
            return false, LANGUAGE.ERROR_OCCURRENCE_ID_NOT_INFORMED
        end
    
        if not suspectId then
            return false, LANGUAGE.ERROR_SUSPECT_ID_NOT_INFORMED
        end
    
        local success, result = Ocurrences:Update(ocurrenceId, suspectId, crimes)
    
        if not success then
            return false, result
        end
    
        return true, {
            result.id,
            result.suspectId,
            result.suspectDescription,
            result.isFinished,
            result.payload.sentence,
            result.payload.fine,
            result.payload.bail,
            result.crimes
        }
    end
    
    function api.deleteRegister(ocurrenceId)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice, policeOrganization = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return
        end
        
        local canDelete = executeAdapter('canDeleteRegister', playerSource, policeOrganization)
    
        if not canDelete then
            return
        end
    
        local status, errorMessage = Ocurrences:Delete(ocurrenceId)
    
        return status, errorMessage
    end
    
    function api.finishRegister(ocurrenceId)
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return
        end
    
        local occurrence = Ocurrences:Get(ocurrenceId)
    
        if not occurrence then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        if occurrence.isFinished then
            return true, LANGUAGE.PRISON_FINISH_SUCCESS
        end
    
        local suspectId = occurrence.suspectId
        local prisonSentence = tonumber(occurrence.payload and occurrence.payload.sentence) or 0
        local suspectSource = executeAdapter('getSourceFromPlayerId', suspectId)
        local officerId = executeAdapter('getPlayerId', playerSource)
    
        local updated = executeAdapter('updateOcurrenceFinished', ocurrenceId, true)
    
        if not updated then
            return false, LANGUAGE.ERROR_OCCURRENCE_UPDATE_DB
        end
    
        local status, errorMessage = Prison:Create(suspectId, ocurrenceId, prisonSentence, officerId, suspectSource)
    
        if not status then
            executeAdapter('updateOcurrenceFinished', ocurrenceId, false)
    
            return false, errorMessage
        end
    
        occurrence.isFinished = true
        addInventoryMissionMdtPrison(playerSource)
        
        if suspectSource then
            return true, LANGUAGE.PRISON_FINISH_SUCCESS
        end
    
        return true, LANGUAGE.PRISON_FINISH_SUCCESS_OFFLINE
    end
    
    function api.getServerRegisters()
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return {}
        end
    
        local playerSource = source
        local isPolice = executeAdapter('isPlayerPolice', playerSource)
    
        if not isPolice then
            return {}
        end
    
        local formattedRegisters = {}
        local serverOccurences = Ocurrences:Get()
    
        for ocurrenceId, ocurrenceData in pairs(serverOccurences) do
            local officerId = ocurrenceData.officerId
            local officerName = executeAdapter('getPlayerName', officerId)
    
            local suspectId = ocurrenceData.suspectId
            local suspectName = executeAdapter('getPlayerName', suspectId)
            local suspectIdentity = executeAdapter('getPlayerRegistration', suspectId)
    
            local formattedDate = formatTimestamp(ocurrenceData.createdAt)
    
            table.insert(formattedRegisters, {
                ocurrenceId,
                officerId,
                officerName,
                suspectId,
                suspectName,
                suspectIdentity,
                ocurrenceData.crimes,
                ocurrenceData.suspectDescription,
                ocurrenceData.payload.sentence,
                ocurrenceData.payload.fine,
                ocurrenceData.payload.bail,
                formattedDate,
                ocurrenceData.isFinished
            })
        end
    
        return formattedRegisters
    end
    
end)
importModule('server/api/Ocurrences')

createModule('server/api/Officers', function()
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
    
end)
importModule('server/api/Officers')

createModule('server/api/Reports', function()
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
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
    
end)
importModule('server/api/Reports')

createModule('server/events/OnPlayerSpawn', function()
    local LastPlayerSpawnAt = {}
    
    RegisterNetEvent('cc_mdt:onPlayerSpawn', function()
        local playerSource = source
        local currentTime = os.time()
    
        if LastPlayerSpawnAt[playerSource] and (currentTime - LastPlayerSpawnAt[playerSource]) < 5 then
            return
        end
    
        LastPlayerSpawnAt[playerSource] = currentTime
    
        local timeoutAt = GetGameTimer() + 30000
    
        while not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL and GetGameTimer() < timeoutAt do
            Citizen.Wait(1000)
        end
    
        if not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
            return
        end
    
        local playerId = executeAdapter('getPlayerId', playerSource)
    
        while not playerId and GetGameTimer() < timeoutAt do
            if GetPlayerPing(playerSource) <= 0 then
                return
            end
    
            playerId = executeAdapter('getPlayerId', playerSource)
    
            Citizen.Wait(1000)
        end
    
        if not playerId then
            return
        end
    
        Prison:OnPlayerSpawn(playerSource, playerId)
    end)
    
end)
importModule('server/events/OnPlayerSpawn')

createModule('server/events/OnResourceStart', function()
    Citizen.CreateThread(function()
        while not _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL do
            Citizen.Wait(1000)
        end
        
        executeAdapter('createDatabaseTables')
    
        Citizen.Wait(1000)
    
        Ocurrences:OnResourceStart()
        FineRecord:OnResourceStart()
        Prison:OnResourceStart()
        Interface:OnResourceStart()
        ProfilePhotos:Setup()
    end)
    
end)
importModule('server/events/OnResourceStart')

createModule('server/events/OnResourceStop', function()
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then
            return
        end
    
        Prison:OnResourceStop()
    end)
    
end)
importModule('server/events/OnResourceStop')

createModule('server/events/PlayerDropped', function()
    AddEventHandler('playerDropped', function()
        local playerSource = source
    
        Prison:OnPlayerDropped(playerSource)
        Interface:OnPlayerClose(playerSource)
    end)
    
end)
importModule('server/events/PlayerDropped')

createModule('server/handlers/FineRecord', function()
    _G.FineRecord = {
        cache = {}
    }
    
    local VALID_FINE_RECORD_TYPES = {
        USER = true,
        VEHICLE = true
    }
    
    local function normalizeFineRecordType(recordType)
        local normalizedType = tostring(recordType or ''):upper()
    
        if VALID_FINE_RECORD_TYPES[normalizedType] then
            return normalizedType
        end
    end
    
    local function normalizeFineRecordTarget(targetIdentifier)
        if targetIdentifier == nil then
            return
        end
    
        local normalizedTarget = tostring(targetIdentifier)
    
        if normalizedTarget == '' then
            return
        end
    
        return normalizedTarget
    end
    
    local function normalizeFineRecordValue(fineValue)
        local parsedValue = math.floor(tonumber(fineValue) or 0)
    
        if parsedValue < 0 then
            return 0
        end
    
        return parsedValue
    end
    
    function FineRecord:OnResourceStart()
        self.cache = executeAdapter('getDatabaseFineRecords')
    end
    
    function FineRecord:Get(recordId)
        if recordId then
            return self.cache[recordId]
        end
    
        return self.cache
    end
    
    function FineRecord:GetByPlayerId(playerId)
        local targetPlayerId = normalizeFineRecordTarget(playerId)
        local formattedRecords = {}
    
        if not targetPlayerId then
            return formattedRecords
        end
    
        for recordId, recordData in pairs(self.cache) do
            if recordData.type == 'USER' and tostring(recordData.targetIdentifier) == targetPlayerId then
                formattedRecords[recordId] = recordData
            end
        end
    
        return formattedRecords
    end
    
    function FineRecord:GetByVehiclePlate(vehiclePlate)
        local targetVehiclePlate = normalizeFineRecordTarget(vehiclePlate)
        local formattedRecords = {}
    
        if not targetVehiclePlate then
            return formattedRecords
        end
    
        targetVehiclePlate = targetVehiclePlate:upper():gsub('%s+', ''):gsub('%-', '')
    
        for recordId, recordData in pairs(self.cache) do
            if recordData.type == 'VEHICLE' then
                local recordPlate = tostring(recordData.targetIdentifier):upper():gsub('%s+', ''):gsub('%-', '')
    
                if recordPlate == targetVehiclePlate then
                    formattedRecords[recordId] = recordData
                end
            end
        end
    
        return formattedRecords
    end
    
    function FineRecord:Create(recordType, targetIdentifier, fineId, description, fineValue, officerId)
        local normalizedType = normalizeFineRecordType(recordType)
    
        if not normalizedType then
            return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
        end
    
        local normalizedTarget = normalizeFineRecordTarget(targetIdentifier)
    
        if not normalizedTarget then
            return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
        end
    
        if not fineId then
            return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
        end
    
        local createdRecordId = executeAdapter(
            'createFineRecord',
            normalizedType,
            normalizedTarget,
            fineId,
            description,
            fineValue,
            officerId
        )
    
        if not createdRecordId then
            return false, LANGUAGE.FINE_RECORD_CAN_NOT_CREATED_ID
        end
    
        self.cache[createdRecordId] = {
            id = createdRecordId,
            type = normalizedType,
            targetIdentifier = normalizedTarget,
            fineId = tonumber(fineId) or fineId,
            description = tostring(description or ''),
            value = normalizeFineRecordValue(fineValue),
            officerId = tostring(officerId or ''),
            createdAt = os.time()
        }
    
        return true, createdRecordId
    end
    
    function FineRecord:CreateMany(recordType, targetIdentifier, fineEntries, officerId)
        local normalizedType = normalizeFineRecordType(recordType)
    
        if not normalizedType then
            return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
        end
    
        local normalizedTarget = normalizeFineRecordTarget(targetIdentifier)
    
        if not normalizedTarget then
            return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
        end
    
        if type(fineEntries) ~= 'table' or #fineEntries == 0 then
            return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
        end
    
        local recordsToInsert = {}
        local createdIds = {}
        local nextTemporaryId = 0
    
        for _, fineEntry in ipairs(fineEntries) do
            if fineEntry and fineEntry.fineId then
                recordsToInsert[#recordsToInsert + 1] = {
                    fineId = tonumber(fineEntry.fineId) or fineEntry.fineId,
                    description = tostring(fineEntry.description or ''),
                    value = normalizeFineRecordValue(fineEntry.value),
                    officerId = tostring(officerId or '')
                }
            end
        end
    
        if #recordsToInsert == 0 then
            return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
        end
    
        local firstInsertId = executeAdapter('createFineRecords', normalizedType, normalizedTarget, recordsToInsert, officerId)
    
        if not firstInsertId then
            return false, LANGUAGE.FINE_RECORD_CAN_NOT_CREATED_ID
        end
    
        for i, recordData in ipairs(recordsToInsert) do
            local recordId = firstInsertId + (i - 1)
    
            self.cache[recordId] = {
                id = recordId,
                type = normalizedType,
                targetIdentifier = normalizedTarget,
                fineId = recordData.fineId,
                description = recordData.description,
                value = recordData.value,
                officerId = recordData.officerId,
                createdAt = os.time()
            }
    
            createdIds[#createdIds + 1] = recordId
        end
    
        return true, createdIds
    end
    
    function FineRecord:Update(recordId, recordType, targetIdentifier, fineId, description, fineValue, officerId)
        local cachedRecord = self:Get(recordId)
    
        if not cachedRecord then
            return false, LANGUAGE.FINE_RECORD_NOT_FOUND
        end
    
        local normalizedType = normalizeFineRecordType(recordType or cachedRecord.type)
    
        if not normalizedType then
            return false, LANGUAGE.FINE_RECORD_INVALID_TYPE
        end
    
        local normalizedTarget = normalizeFineRecordTarget(targetIdentifier or cachedRecord.targetIdentifier)
    
        if not normalizedTarget then
            return false, LANGUAGE.FINE_RECORD_TARGET_REQUIRED
        end
    
        local nextFineId = fineId or cachedRecord.fineId
    
        if not nextFineId then
            return false, LANGUAGE.FINE_RECORD_FINE_ID_REQUIRED
        end
    
        local updatedRecord = {
            type = normalizedType,
            targetIdentifier = normalizedTarget,
            fineId = tonumber(nextFineId) or nextFineId,
            description = tostring(description ~= nil and description or cachedRecord.description or ''),
            value = normalizeFineRecordValue(fineValue ~= nil and fineValue or cachedRecord.value),
            officerId = tostring(officerId ~= nil and officerId or cachedRecord.officerId or '')
        }
    
        executeAdapter(
            'updateFineRecord',
            recordId,
            updatedRecord.type,
            updatedRecord.targetIdentifier,
            updatedRecord.fineId,
            updatedRecord.description,
            updatedRecord.value,
            updatedRecord.officerId
        )
    
        cachedRecord.type = updatedRecord.type
        cachedRecord.targetIdentifier = updatedRecord.targetIdentifier
        cachedRecord.fineId = updatedRecord.fineId
        cachedRecord.description = updatedRecord.description
        cachedRecord.value = updatedRecord.value
        cachedRecord.officerId = updatedRecord.officerId
    
        return true, cachedRecord
    end
    
    function FineRecord:Delete(recordId)
        if not self.cache[recordId] then
            return false, LANGUAGE.FINE_RECORD_NOT_FOUND
        end
    
        local success = executeAdapter('deleteFineRecord', recordId)
    
        if not success then
            return false, LANGUAGE.FINE_RECORD_NOT_FOUND
        end
    
        self.cache[recordId] = nil
    
        return true
    end
    
end)
importModule('server/handlers/FineRecord')

createModule('server/handlers/Interface', function()
    _G.Interface = {
        cache = {}
    }
    
    local function getPlayerCoordsBySource(playerSource)
        if not playerSource then
            return { 0, 0, 0 }
        end
    
        local officerPed = GetPlayerPed(playerSource)
    
        if not officerPed or officerPed <= 0 or not DoesEntityExist(officerPed) then
            return { 0, 0, 0 }
        end
    
        local officerCoordinates = GetEntityCoords(officerPed)
    
        if not officerCoordinates then
            return { 0, 0, 0 }
        end
    
        local x = tonumber(officerCoordinates.x)
        local y = tonumber(officerCoordinates.y)
        local z = tonumber(officerCoordinates.z)
    
        if not x or not y or not z then
            return { 0, 0, 0 }
        end
    
        return { x, y, z }
    end
    
    function Interface:OnPlayerOpen(playerSource)
        if self.cache[playerSource] then
            return
        end
    
        local playerId = executeAdapter('getPlayerId', playerSource)
    
        if not playerId then
            return
        end
    
        local playerName = executeAdapter('getPlayerName', playerId)
    
        self.cache[playerSource] = { 
            id = playerId, 
            name = playerName 
        }
    end
    
    function Interface:OnPlayerClose(playerSource)
        self.cache[playerSource] = nil
    end
    
    function Interface:IsPlayerInterfaceOpen(searchSource)
        return not not self.cache[searchSource]
    end
    
    function Interface:GetAllOpenInterfaces()
        return self.cache
    end
    
    function Interface:OnResourceStart()
        Citizen.CreateThread(function()
            while true do
                if _borVezEyCpiBVKtqIsTJyYevegJxvClsmuXaNsEcJGqTuxDSaLJDRjmHwpxlRFjL then
                    local formattedEntries = {}
                    local onlinePolicesInService = executeAdapter('getOnlinePolicesInService')
    
                    for _, player in ipairs(onlinePolicesInService) do
                        local playerCoords = getPlayerCoordsBySource(player.source)
                        local playerName = self.cache[player.source] and self.cache[player.source].name or executeAdapter('getPlayerName', player.id)
                        local ORG_CONFIG = ORGANIZATIONS_CONFIG[player.organization] or { MAP_COLOR = '#0000ff' }
    
                        formattedEntries[#formattedEntries + 1] = { player.id, playerName, playerCoords, ORG_CONFIG.MAP_COLOR }
                    end
    
                    for playerSource in pairs(self.cache) do
                        TriggerClientEvent('cc_mdt:updateOfficersOnMap', playerSource, formattedEntries)
                    end
                end
    
                Citizen.Wait(GENERAL_CONFIG.TIME_TO_UPDATE_OFFICERS_MAP)
            end
        end)
    end
    
end)
importModule('server/handlers/Interface')

createModule('server/handlers/Ocurrences', function()
    _G.Ocurrences = {
        cache = {}
    }
    
    function Ocurrences:OnResourceStart()
        self.cache = executeAdapter('getDatabaseOcurrences')
    end
    
    local function normalizeIdList(values, allowedValues)
        local normalized = {}
        local added = {}
    
        if type(values) ~= 'table' then
            return normalized
        end
    
        for _, value in ipairs(values) do
            local id = tonumber(value)
    
            if id and allowedValues[id] and not added[id] then
                normalized[#normalized + 1] = id
                added[id] = true
            end
        end
    
        return normalized
    end
    
    local function calculateOcurrencePayload(crimes, attenuants, aggravants)
        local totalFine = 0
        local totalBail = 0
        local totalSentence = 0
        local isBailable = true
    
        for _, crimeId in ipairs(crimes) do
            local crime = LEGISLATION_CONFIG.PENAL_CODES[crimeId]
    
            if crime then
                totalFine = totalFine + crime.FINE
                totalSentence = totalSentence + crime.SENTENCE
    
                if crime.BAIL == false then
                    isBailable = false
                else
                    totalBail = totalBail + crime.BAIL
                end
            end
        end
    
        local aggravantPercentage = 0
    
        for _, aggravantId in ipairs(aggravants) do
            local factor = LEGISLATION_CONFIG.AGGRAVATING_FACTORS[aggravantId]
    
            if factor then
                aggravantPercentage = aggravantPercentage + factor.PERCENTAGE
            end
        end
    
        local attenuantPercentage = 0
    
        for _, attenuantId in ipairs(attenuants) do
            local factor = LEGISLATION_CONFIG.ATTENUANTS_FACTORS[attenuantId]
    
            if factor then
                attenuantPercentage = attenuantPercentage + factor.PERCENTAGE
            end
        end
    
        local netPercentage = aggravantPercentage - attenuantPercentage
        local multiplier = 1 + (netPercentage / 100)
    
        totalSentence = math.max(1, math.floor(totalSentence * multiplier))
        totalFine = math.max(0, math.floor(totalFine * multiplier))
        totalBail = isBailable and math.max(0, math.floor(totalBail * multiplier)) or false
    
        return {
            fine = totalFine,
            bail = totalBail,
            isBailable = isBailable,
            sentence = totalSentence
        }
    end
    
    function Ocurrences:Create(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL)
        if not suspectId or not crimes then
            return false, LANGUAGE.ERROR_REQUIRED_PARAMS
        end
    
        crimes = normalizeIdList(crimes, LEGISLATION_CONFIG.PENAL_CODES)
        attenuants = normalizeIdList(attenuants, LEGISLATION_CONFIG.ATTENUANTS_FACTORS)
        aggravants = normalizeIdList(aggravants, LEGISLATION_CONFIG.AGGRAVATING_FACTORS)
    
        if #crimes == 0 then
            return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
        end
    
        local penaltyPayload = calculateOcurrencePayload(crimes, attenuants, aggravants)
        local ocurrenceId = executeAdapter('createOcurrence', officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL, penaltyPayload)
    
        if not ocurrenceId then
            return false, LANGUAGE.ERROR_OCCURRENCE_CREATED_ID
        end
    
        self.cache[ocurrenceId] = {
            id = ocurrenceId,
            officerId = officerId,
            suspectId = suspectId,
            suspectDescription = suspectDescription,
            crimes = crimes,
            attenuants = attenuants or {},
            aggravants = aggravants or {},
            photoURL = photoURL,
            payload = penaltyPayload,
            isFinished = false,
            createdAt = os.time()
        }
    
        return true, ocurrenceId
    end
    
    function Ocurrences:Update(ocurrenceId, newSuspectId, newCrimes)
        local cached = self:Get(ocurrenceId)
    
        if not cached then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        local params = {}
        local updates = {}
        local setClauses = {}
    
        if newSuspectId and newSuspectId ~= cached.suspectId then
            setClauses[#setClauses + 1] = 'suspect_id = ?'
            params[#params + 1] = newSuspectId
            updates.suspectId = newSuspectId
        end
    
        local crimesChanged = false
    
        if newCrimes then
            newCrimes = normalizeIdList(newCrimes, LEGISLATION_CONFIG.PENAL_CODES)
    
            if #newCrimes == 0 then
                return false, LANGUAGE.ERROR_NO_CRIME_INFORMED
            end
    
            cached.crimes = cached.crimes or {}
    
            if #newCrimes ~= #cached.crimes then
                crimesChanged = true
            else
                for i, id in ipairs(newCrimes) do
                    if cached.crimes[i] ~= id then
                        crimesChanged = true
                        break
                    end
                end
            end
        end
    
        if crimesChanged then
            local newPayload = calculateOcurrencePayload(newCrimes, cached.attenuants, cached.aggravants)
    
            setClauses[#setClauses + 1] = 'crimes = ?'
            params[#params + 1] = json.encode(newCrimes)
    
            setClauses[#setClauses + 1] = 'payload = ?'
            params[#params + 1] = json.encode(newPayload)
    
            updates.crimes = newCrimes
            updates.payload = newPayload
        end
    
        if #setClauses == 0 then
            return false, LANGUAGE.ERROR_NO_CHANGES_DETECTED
        end
    
        local success = executeAdapter('updateOcurrence', ocurrenceId, setClauses, params)
    
        if not success then
            return false, LANGUAGE.ERROR_OCCURRENCE_UPDATE_DB
        end
    
        for key, value in pairs(updates) do
            cached[key] = value
        end
    
        return true, cached
    end
    
    function Ocurrences:Delete(ocurrenceId)
        if not ocurrenceId or not self.cache[ocurrenceId] then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        local success = executeAdapter('deleteOcurrence', ocurrenceId)
    
        if not success then
            return false, LANGUAGE.ERROR_OCCURRENCE_DELETE_DB
        end
    
        self.cache[ocurrenceId] = nil
    
        return true
    end
    
    function Ocurrences:Get(ocurrenceId)
        if ocurrenceId then
            return self.cache[ocurrenceId]
        end
    
        return self.cache
    end
    
end)
importModule('server/handlers/Ocurrences')

createModule('server/handlers/Prison', function()
    _G.Prison = {
        cache = {}
    }
    
    local PRISON_MONTH_DURATION_SECONDS = 60
    local PRISON_TICK_SECONDS = 1
    local PRISON_TASK_MAX_DISTANCE = 5.0
    local PRISON_TASK_FINISH_TOLERANCE_SECONDS = 2
    local PRISON_TASK_COOLDOWN_SECONDS = 5
    
    local function getPrisonOutfit(playerSource)
        local playerPed = GetPlayerPed(playerSource)
        local playerModel = playerPed > 0 and GetEntityModel(playerPed) or nil
    
        if playerModel and PRISON_CONFIG.CLOTHES_TO_SET[playerModel] then
            return PRISON_CONFIG.CLOTHES_TO_SET[playerModel]
        end
    
        return PRISON_CONFIG.CLOTHES_TO_SET[GetHashKey('mp_m_freemode_01')]
    end
    
    local function normalizeRemainingSeconds(releaseTick)
        local remainingSeconds = math.max(0, math.floor(tonumber(releaseTick) or 0))
    
        if remainingSeconds > 1000000000 then
            remainingSeconds = math.max(0, remainingSeconds - os.time())
        end
    
        return remainingSeconds
    end
    
    local function getRemainingSentence(prisonRecord)
        local remainingSeconds = math.max(0, math.floor(tonumber(prisonRecord and prisonRecord.remainingSeconds) or 0))
    
        if remainingSeconds <= 0 then
            return 0
        end
    
        return math.max(1, math.ceil(remainingSeconds / PRISON_MONTH_DURATION_SECONDS))
    end
    
    local function getTaskByIndex(taskIndex)
        local normalizedTaskIndex = tonumber(taskIndex)
    
        if not normalizedTaskIndex or not PRISON_CONFIG.TASKS then
            return nil
        end
    
        return PRISON_CONFIG.TASKS[normalizedTaskIndex], normalizedTaskIndex
    end
    
    local function getPlayerDistanceToTask(playerSource, task)
        if not playerSource or not task or not task.LOCATION or not task.LOCATION.COORDINATES then
            return nil
        end
    
        local playerPed = GetPlayerPed(playerSource)
    
        if not playerPed or playerPed <= 0 or not DoesEntityExist(playerPed) then
            return nil
        end
    
        local playerCoords = GetEntityCoords(playerPed)
        local taskCoords = task.LOCATION.COORDINATES
        local playerX = tonumber(playerCoords.x)
        local playerY = tonumber(playerCoords.y)
        local playerZ = tonumber(playerCoords.z)
        local taskX = tonumber(taskCoords.x)
        local taskY = tonumber(taskCoords.y)
        local taskZ = tonumber(taskCoords.z)
    
        if not playerX or not playerY or not playerZ or not taskX or not taskY or not taskZ then
            return nil
        end
    
        local dx = playerX - taskX
        local dy = playerY - taskY
        local dz = playerZ - taskZ
    
        return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
    end
    
    local function isPlayerNearTask(playerSource, task)
        local distance = getPlayerDistanceToTask(playerSource, task)
    
        return distance and distance <= PRISON_TASK_MAX_DISTANCE
    end
    
    local function getMaxTaskReduce()
        local maxReduce = 0
    
        for _, task in ipairs(PRISON_CONFIG.TASKS or {}) do
            maxReduce = math.max(maxReduce, math.floor(tonumber(task.REDUCE) or 0))
        end
    
        return maxReduce
    end
    
    local function persistPrisonRecord(playerId, prisonRecord)
        executeAdapter(
            'executeAsync',
            'UPDATE cc_mdt_player_prisons SET sentence = ?, release_at = ? WHERE player_id = ?',
            {
                tonumber(prisonRecord.sentence) or 0,
                tonumber(prisonRecord.remainingSeconds) or 0,
                tostring(playerId)
            }
        )
    end
    
    function Prison:NormalizeRecord(prisonRecord)
        if not prisonRecord then
            return nil
        end
    
        prisonRecord.remainingSeconds = normalizeRemainingSeconds(prisonRecord.remainingSeconds or prisonRecord.releaseTick)
        prisonRecord.sentence = math.max(0, math.floor(tonumber(prisonRecord.sentence) or getRemainingSentence(prisonRecord)))
        prisonRecord.releaseTick = prisonRecord.remainingSeconds
        prisonRecord.taskSequenceIndex = tonumber(prisonRecord.taskSequenceIndex) or 1
    
        return prisonRecord
    end
    
    function Prison:OnResourceStart()
        self.cache = executeAdapter('getDatabasePrisonRecords') or {}
    
        for playerId, prisonRecord in pairs(self.cache) do
            self.cache[playerId] = self:NormalizeRecord(prisonRecord)
        end
    
        Citizen.CreateThread(function()
            while true do
                self:ProcessOnlinePrisoners()
                Citizen.Wait(PRISON_TICK_SECONDS * 1000)
            end
        end)
    
        self:ResumeActivePrisoners()
    end
    
    function Prison:OnResourceStop()
        for playerId, prisonRecord in pairs(self.cache) do
            if prisonRecord then
                self:SyncPrisonRecord(playerId, prisonRecord)
            end
        end
    end
    
    function Prison:ResumeActivePrisoners()
        for playerId, prisonRecord in pairs(self.cache) do
            prisonRecord = self:NormalizeRecord(prisonRecord)
    
            self.cache[playerId] = prisonRecord
    
            if prisonRecord and prisonRecord.remainingSeconds <= 0 then
                self:Release(playerId, true)
            else
                local playerSource = executeAdapter('getSourceFromPlayerId', playerId)
    
                if playerSource then
                    self:ApplyToPlayer(playerSource, playerId)
                end
            end
        end
    end
    
    function Prison:SyncPrisonRecord(playerId, prisonRecord)
        if not prisonRecord then
            return false
        end
    
        prisonRecord.sentence = math.max(0, math.floor(tonumber(prisonRecord.sentence) or 0))
        prisonRecord.remainingSeconds = math.max(0, math.floor(tonumber(prisonRecord.remainingSeconds) or 0))
        prisonRecord.releaseTick = prisonRecord.remainingSeconds
    
        persistPrisonRecord(playerId, prisonRecord)
    
        return true
    end
    
    function Prison:Get(playerId)
        if playerId then
            return self.cache[tostring(playerId)]
        end
    
        return self.cache
    end
    
    function Prison:IsActive(playerId)
        return not not self:Get(playerId)
    end
    
    function Prison:Create(playerId, occurrenceId, sentenceMonths, officerId, playerSource)
        local normalizedOccurrenceId = tonumber(occurrenceId) or occurrenceId
        local prisonSentence = math.max(1, math.floor(tonumber(sentenceMonths) or 0))
        local normalizedPlayerId = tostring(playerId)
    
        if prisonSentence <= 0 then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local remainingSeconds = prisonSentence * PRISON_MONTH_DURATION_SECONDS
        local originalClothes = nil
    
        if playerSource then
            local clothes = apiClient.getPlayerClothes(playerSource)
    
            if type(clothes) == 'table' then
                originalClothes = clothes
            end
        end
    
        local persisted = executeAdapter(
            'upsertPrisonRecord',
            normalizedPlayerId,
            normalizedOccurrenceId,
            tostring(officerId or ''),
            prisonSentence,
            remainingSeconds,
            originalClothes and json.encode(originalClothes) or nil
        )
    
        if not persisted then
            return false, LANGUAGE.ERROR_PRISON_UPDATE_DB
        end
    
        self.cache[normalizedPlayerId] = {
            playerId = normalizedPlayerId,
            occurrenceId = normalizedOccurrenceId,
            officerId = tostring(officerId or ''),
            sentence = prisonSentence,
            remainingSeconds = remainingSeconds,
            releaseTick = remainingSeconds,
            originalClothes = originalClothes,
            taskSequenceIndex = 1,
            createdAt = os.time()
        }
    
        if playerSource then
            if not originalClothes then
                local storedClothes = apiClient.getPlayerClothes(playerSource)
    
                if type(storedClothes) == 'table' then
                    originalClothes = storedClothes
    
                    self.cache[normalizedPlayerId].originalClothes = storedClothes
    
                    executeAdapter('updatePrisonRecordClothes', normalizedPlayerId, json.encode(storedClothes))
                end
            end
    
            self:ApplyToPlayer(playerSource, normalizedPlayerId)
    
            executeAdapter('notifyPlayer', playerSource, LANGUAGE.PRISON_PRISONED:format(prisonSentence))
        end
    
        return true
    end
    
    function Prison:ApplyToPlayer(playerSource, playerId)
        local prisonRecord = self.cache[tostring(playerId)]
    
        if not prisonRecord then
            return false
        end
    
        local prisonOutfit = getPrisonOutfit(playerSource)
    
        if prisonOutfit then
            apiClient.setPlayerClothes(playerSource, prisonOutfit)
        end
    
        apiClient.prisonPlayer(playerSource, getRemainingSentence(prisonRecord), prisonRecord.remainingSeconds)
    
        return true
    end
    
    function Prison:ReduceSentence(playerId, reduceMinutes)
        local prisonRecord = self.cache[tostring(playerId)]
    
        if not prisonRecord then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        local reduceValue = math.max(0, math.floor(tonumber(reduceMinutes) or 0))
    
        if reduceValue <= 0 or reduceValue > getMaxTaskReduce() then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        prisonRecord.remainingSeconds = math.max(0, (tonumber(prisonRecord.remainingSeconds) or 0) - (reduceValue * PRISON_MONTH_DURATION_SECONDS))
        prisonRecord.releaseTick = prisonRecord.remainingSeconds
        prisonRecord.sentence = getRemainingSentence(prisonRecord)
    
        if prisonRecord.remainingSeconds <= 0 then
            self:Release(playerId, true)
    
            return true, 0, 0
        end
    
        persistPrisonRecord(playerId, prisonRecord)
    
        return true, prisonRecord.sentence, prisonRecord.remainingSeconds
    end
    
    function Prison:StartTask(playerSource, playerId, taskIndex)
        local normalizedPlayerId = tostring(playerId)
        local prisonRecord = self.cache[normalizedPlayerId]
    
        if not prisonRecord then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        local task, normalizedTaskIndex = getTaskByIndex(taskIndex)
    
        if not task then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local taskCount = #(PRISON_CONFIG.TASKS or {})
        local expectedTaskIndex = tonumber(prisonRecord.taskSequenceIndex) or 1
    
        if taskCount > 0 and normalizedTaskIndex ~= expectedTaskIndex then
            return false, LANGUAGE.PRISON_TASK_NOT_AVAILABLE
        end
    
        local currentTime = os.time()
    
        if prisonRecord.task and prisonRecord.task.expiresAt and prisonRecord.task.expiresAt > currentTime then
            return false, LANGUAGE.PRISON_TASK_ALREADY_RUNNING
        end
    
        if prisonRecord.lastTaskFinishedAt and (currentTime - prisonRecord.lastTaskFinishedAt) < PRISON_TASK_COOLDOWN_SECONDS then
            return false, LANGUAGE.PRISON_TASK_COOLDOWN
        end
    
        if not isPlayerNearTask(playerSource, task) then
            return false, LANGUAGE.PRISON_TASK_NOT_NEAR
        end
    
        local duration = math.max(1, math.floor(tonumber(task.DURATION_SECONDS) or 0))
        local reduce = math.max(0, math.floor(tonumber(task.REDUCE) or 0))
    
        if reduce <= 0 then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        prisonRecord.task = {
            index = normalizedTaskIndex,
            startedAt = currentTime,
            duration = duration,
            reduce = reduce,
            expiresAt = currentTime + duration + 30
        }
    
        return true
    end
    
    function Prison:CompleteTask(playerSource, playerId, taskIndex)
        local normalizedPlayerId = tostring(playerId)
        local prisonRecord = self.cache[normalizedPlayerId]
    
        if not prisonRecord then
            return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
        end
    
        local task, normalizedTaskIndex = getTaskByIndex(taskIndex)
        local taskState = prisonRecord.task
    
        if not task or not taskState or taskState.index ~= normalizedTaskIndex then
            return false, LANGUAGE.COMMON_REQUIRED_PARAMS
        end
    
        local currentTime = os.time()
        local elapsed = currentTime - (tonumber(taskState.startedAt) or currentTime)
        local requiredDuration = math.max(1, (tonumber(taskState.duration) or tonumber(task.DURATION_SECONDS) or 0) - PRISON_TASK_FINISH_TOLERANCE_SECONDS)
    
        if elapsed < requiredDuration then
            return false, LANGUAGE.PRISON_TASK_NOT_FINISHED
        end
    
        if taskState.expiresAt and currentTime > taskState.expiresAt then
            prisonRecord.task = nil
    
            return false, LANGUAGE.PRISON_TASK_EXPIRED
        end
    
        if not isPlayerNearTask(playerSource, task) then
            return false, LANGUAGE.PRISON_TASK_NOT_NEAR
        end
    
        local reduce = math.max(0, math.floor(tonumber(taskState.reduce) or tonumber(task.REDUCE) or 0))
    
        prisonRecord.task = nil
        prisonRecord.lastTaskFinishedAt = currentTime
    
        local success, sentence, releaseTick = self:ReduceSentence(normalizedPlayerId, reduce)
    
        if success and self.cache[normalizedPlayerId] then
            local taskCount = #(PRISON_CONFIG.TASKS or {})
    
            if taskCount > 0 then
                local nextTaskIndex = normalizedTaskIndex + 1
    
                if nextTaskIndex > taskCount then
                    nextTaskIndex = 1
                end
    
                self.cache[normalizedPlayerId].taskSequenceIndex = nextTaskIndex
            end
        end
    
        return success, sentence, releaseTick
    end
    
    function Prison:Release(playerId, shouldRestoreClothes)
        local normalizedPlayerId = tostring(playerId)
        local prisonRecord = self.cache[normalizedPlayerId]
    
        if not prisonRecord then
            return false
        end
    
        local deleted = executeAdapter('deletePrisonRecord', normalizedPlayerId)
    
        if not deleted then
            return false, LANGUAGE.ERROR_PRISON_UPDATE_DB
        end
    
        local playerSource = executeAdapter('getSourceFromPlayerId', normalizedPlayerId)
    
        if playerSource then
            if shouldRestoreClothes and prisonRecord.originalClothes then
                apiClient.setPlayerClothes(playerSource, prisonRecord.originalClothes)
            end
    
            apiClient.removePrisonPlayer(playerSource, false)
    
            executeAdapter('notifyPlayer', playerSource, LANGUAGE.PRISON_RELEASED)
        end
    
        self.cache[normalizedPlayerId] = nil
    
        return true
    end
    
    function Prison:ProcessOnlinePrisoners()
        for playerId, prisonRecord in pairs(self.cache) do
            prisonRecord = self:NormalizeRecord(prisonRecord)
    
            self.cache[playerId] = prisonRecord
    
            if prisonRecord then
                local playerSource = executeAdapter('getSourceFromPlayerId', playerId)
    
                if playerSource then
                    if prisonRecord.remainingSeconds <= 0 then
                        self:Release(playerId, true)
                    else
                        prisonRecord.remainingSeconds = math.max(0, prisonRecord.remainingSeconds - 1)
                        prisonRecord.releaseTick = prisonRecord.remainingSeconds
                        prisonRecord.sentence = getRemainingSentence(prisonRecord)
    
                        if prisonRecord.remainingSeconds <= 0 then
                            self:Release(playerId, true)
                        end
                    end
                end
            end
        end
    end
    
    function Prison:OnPlayerSpawn(playerSource, playerId)
        local prisonRecord = self.cache[tostring(playerId)]
    
        if not prisonRecord then
            return
        end
    
        prisonRecord = self:NormalizeRecord(prisonRecord)
    
        self.cache[tostring(playerId)] = prisonRecord
    
        if prisonRecord.remainingSeconds <= 0 then
            self:Release(playerId, true)
            
            return
        end
    
        self:ApplyToPlayer(playerSource, tostring(playerId))
    end
    
    function Prison:OnPlayerDropped(playerSource)
        local playerId = executeAdapter('getPlayerId', playerSource)
    
        if not playerId then
            return
        end
    
        local prisonRecord = self.cache[tostring(playerId)]
    
        if not prisonRecord then
            return
        end
    
        self:SyncPrisonRecord(playerId, prisonRecord)
    end
    
end)
importModule('server/handlers/Prison')

createModule('server/handlers/ProfilePhotos', function()
    _G.ProfilePhotos = {
        cache = {}
    }
    
    function ProfilePhotos:Setup()
        self.cache = executeAdapter('getDatabaseProfilePhotos')
    end
    
    function ProfilePhotos:SetPhoto(playerId, photoUrl)
        self.cache[playerId] = photoUrl
    
        executeAdapter('updatePlayerProfilePhoto', playerId, photoUrl)
    end
    
    function ProfilePhotos:GetPhoto(playerId)
        if playerId then
            return self.cache[playerId] or ''
        end
    
        return self.cache
    end
end)
importModule('server/handlers/ProfilePhotos')
