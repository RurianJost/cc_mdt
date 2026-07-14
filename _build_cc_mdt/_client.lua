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

createModule('client/main', function()
    apiServer = Tunnel.getInterface('cc_mdt')
    
    api = {}
    Tunnel.bindInterface('cc_mdt', api)
    
    if not LPH_OBFUSCATED then
        LPH_NO_VIRTUALIZE = function(...) 
            return ... 
        end
    end
    
    function interfaceQueue(handler)
        local isWaiting = false 
    
        return function(data, responseCallback)
            if isWaiting then 
                return 
            end 
    
            isWaiting = true 
    
            handler(data, responseCallback)
            
            isWaiting = false
        end 
    end 
    
    _RegisterNUICallback = RegisterNUICallback 
    
    function RegisterNUICallback(name, handler)
        return _RegisterNUICallback(name, interfaceQueue(handler))
    end 
    
    executeAdapter('registerHandler', function()
        local canOpenPainel = apiServer.canOpenPainel()
    
        if canOpenPainel then 
            openInterface()
        end
    end)
    
end)
importModule('client/main')

createModule('client/api/Prison', function()
    function api.prisonPlayer(sentence, releaseTick)
        Prison:Insert(sentence, releaseTick)
    end
    
    function api.removePrisonPlayer(isScaped)
        Prison:Remove(isScaped)
    end
    
    function api.updatePrisonSentence(sentence, releaseTick)
        Prison:UpdateSentence(sentence, releaseTick)
    end
    
    function api.getPlayerClothes()
        local playerPed = PlayerPedId()
    
        return executeAdapter('getPlayerClothes', playerPed)
    end
    
    function api.setPlayerClothes(clothesToSet)
        local playerPed = PlayerPedId()
    
        executeAdapter('setClothesOnPlayer', playerPed, clothesToSet)
    end
    
end)
importModule('client/api/Prison')

createModule('client/api/Request', function()
    local requestPromise = nil 
    
    function api.createRequest(requestTitle, requestDescription)
        if requestPromise then
            return false
        end
    
        requestPromise = promise.new()
    
        SendNUIMessage({
            action = 'showRequest', 
            data = {
                title = requestTitle, 
                description = requestDescription
            }
        })
    
        local requestResponse = Citizen.Await(requestPromise)
        
        SendNUIMessage({
            action = 'hideRequest', 
            data = {}
        })
    
        requestPromise = nil
    
        return requestResponse
    end
    
    local function acceptRequest()
        if requestPromise then
            requestPromise:resolve(true)
        end
    end
    
    local function rejectRequest()
        if requestPromise then
            requestPromise:resolve(false)
        end
    end
    
    RegisterNUICallback('respondPoliceHireRequest', function(data, callback)
        if data and data.accepted then
            acceptRequest()
        else
            rejectRequest()
        end
    
        callback({})
    end)
    
    Citizen.CreateThread(function()
        RegisterCommand('cc_mdt:acceptRequest', function()
            acceptRequest()
        end)
        
        RegisterCommand('cc_mdt:rejectRequest', function()
            rejectRequest()
        end)
        
        RegisterKeyMapping('cc_mdt:acceptRequest', LANGUAGE.REQUEST_ACCEPT_KEYMAPPING, 'KEYBOARD', 'Y')
        RegisterKeyMapping('cc_mdt:rejectRequest', LANGUAGE.REQUEST_REJECT_KEYMAPPING, 'KEYBOARD', 'U')
    end)
    
end)
importModule('client/api/Request')

createModule('client/events/OnResourceStop', function()
    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then 
            return 
        end 
        
    end)
end)
importModule('client/events/OnResourceStop')

createModule('client/events/PlayerSpawned', function()
    Citizen.CreateThread(function()
        TriggerServerEvent('cc_mdt:onPlayerSpawn')
    end)
end)
importModule('client/events/PlayerSpawned')

createModule('client/handlers/Prison', function()
    _G.Prison = {
        cache = {}
    }
    
    local function getTaskByIndex(taskIndex)
        if not PRISON_CONFIG.TASKS then
            return nil
        end
    
        return PRISON_CONFIG.TASKS[taskIndex]
    end
    
    local function getTaskMarker(task)
        if task and task.MARKER then
            return task.MARKER
        end
    
        return {
            TYPE = 1,
            SCALE = vector3(1.0, 1.0, 1.0),
            RGBA = { 255, 255, 255, 180 },
            textureDict = nil,
            textureName = nil
        }
    end
    
    local function getTaskDistance(task, playerCoordinates)
        if not task or not task.LOCATION or not task.LOCATION.COORDINATES then
            return nil
        end
    
        return #(playerCoordinates - task.LOCATION.COORDINATES)
    end
    
    local function drawTaskMarker(task)
        if not task or not task.LOCATION or not task.LOCATION.COORDINATES then
            return
        end
    
        local marker = getTaskMarker(task)
        local scale = marker.SCALE or vector3(1.0, 1.0, 1.0)
        local rgba = marker.RGBA or { 255, 255, 255, 180 }
        local coords = task.LOCATION.COORDINATES
        local textureDict = marker.textureDict
        local textureName = marker.textureName
        local hasTexture = textureDict and textureName and HasStreamedTextureDictLoaded(textureDict)
    
        if textureDict and not hasTexture then
            RequestStreamedTextureDict(textureDict, false)
        end
    
        if hasTexture then
            DrawMarker(
                marker.TYPE or 9,
                coords.x, coords.y, coords.z - 0.95,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                scale.x or 1.0, scale.y or 1.0, scale.z or 1.0,
                rgba[1] or 255, rgba[2] or 255, rgba[3] or 255, rgba[4] or 180,
                false, false, 2, false,
                textureDict, textureName, false
            )
        else
            DrawMarker(
                marker.TYPE or 9,
                coords.x, coords.y, coords.z - 0.95,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                scale.x or 1.0, scale.y or 1.0, scale.z or 1.0,
                rgba[1] or 255, rgba[2] or 255, rgba[3] or 255, rgba[4] or 180,
                false, false, 2, false,
                nil, nil, false
            )
        end
    end
    
    function Prison:UpdateSentence(sentence, releaseTick)
        self.cache.sentence = tonumber(sentence) or self.cache.sentence or 1
        self.cache.releaseTick = tonumber(releaseTick) or self.cache.releaseTick or 0
        self.cache.lastShownSentence = nil
    
        showSentence(self.cache.sentence)
    end
    
    function Prison:GetTaskSequenceIndex()
        local taskCount = #(PRISON_CONFIG.TASKS or {})
    
        if taskCount <= 0 then
            return 1
        end
    
        local currentIndex = tonumber(self.cache.taskState and self.cache.taskState.nextTaskIndex) or 1
    
        if currentIndex < 1 or currentIndex > taskCount then
            currentIndex = 1
        end
    
        return currentIndex
    end
    
    function Prison:AdvanceTaskSequence()
        local taskCount = #(PRISON_CONFIG.TASKS or {})
    
        if taskCount <= 0 then
            self.cache.taskState.nextTaskIndex = 1
            self.cache.taskState.completed = {}
    
            return 1
        end
    
        local nextIndex = (tonumber(self.cache.taskState and self.cache.taskState.nextTaskIndex) or 1) + 1
    
        if nextIndex > taskCount then
            nextIndex = 1
            
            self.cache.taskState.completed = {}
        end
    
        self.cache.taskState.nextTaskIndex = nextIndex
    
        return nextIndex
    end
    
    function Prison:BuildTaskState()
        self.cache.taskState = self.cache.taskState or {}
        self.cache.taskState.completed = self.cache.taskState.completed or {}
        self.cache.taskState.nextTaskIndex = self.cache.taskState.nextTaskIndex or 1
    end
    
    function Prison:StartTask(taskIndex)
        if self.cache.task then
            return false
        end
    
        local task = getTaskByIndex(taskIndex)
    
        if not task then
            return false
        end
    
        local canStart, errorMessage = apiServer.startPrisonTask(taskIndex)
    
        if not canStart then
            executeAdapter('notifyPlayer', errorMessage or LANGUAGE.PRISON_TASK_START_FAILED)
    
            return false
        end
    
        self:BuildTaskState()
    
        local playerPed = PlayerPedId()
        local duration = tonumber(task.DURATION_SECONDS) or 0
        local coords = task.LOCATION and task.LOCATION.COORDINATES
    
        self.cache.task = {
            index = taskIndex,
            data = task,
            startedAt = GetGameTimer(),
            finishAt = GetGameTimer() + (duration * 1000),
            reduce = tonumber(task.REDUCE) or 0,
            object = nil,
            blip = nil,
            allowWalk = task.ANIMATIONS and task.ANIMATIONS.ALLOW_WALK or false
        }
    
        if coords then
            SetEntityCoords(playerPed, coords.x, coords.y, coords.z - 0.98)
            SetEntityHeading(playerPed, task.LOCATION.HEADING or GetEntityHeading(playerPed))
        end
    
        if task.ANIMATIONS then
            executeAdapter('createPrisonTaskAnimation', playerPed, task.ANIMATIONS)
    
            if self.cache.task.allowWalk then
                executeAdapter('setPrisonTaskMovement', playerPed, true)
            end
        end
    
        if task.OBJECT then
            self.cache.task.object = executeAdapter('createPrisonTaskObject', playerPed, task.OBJECT)
        end
    
        if task.LOCATION and task.LOCATION.COORDINATES then
            self.cache.task.blip = executeAdapter('createPrisonTaskBlipLocation', {
                x = task.LOCATION.COORDINATES.x,
                y = task.LOCATION.COORDINATES.y,
                z = task.LOCATION.COORDINATES.z
            }, task.BLIP)
        end
    
        executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_STARTED:format(task.NAME or LANGUAGE.PRISON_TASK_DEFAULT_NAME))
    
        return true
    end
    
    function Prison:CompleteTask()
        if not self.cache.task then
            return false
        end
    
        local task = self.cache.task.data
        local reduceMinutes = self.cache.task.reduce or 0
    
        if reduceMinutes <= 0 then
            self:StopTask()
    
            return false
        end
    
        local success, sentence, releaseTick = apiServer.reducePrisonSentence(self.cache.task.index)
    
        if not success then
            executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_REDUCE_FAILED)
    
            self:StopTask()
    
            return false
        end
    
        if sentence and sentence > 0 then
            executeAdapter('updatePrisonSentence', sentence, releaseTick)
        else
            executeAdapter('updatePrisonSentence', 0, releaseTick)
        end
    
        if self.cache.taskState and self.cache.taskState.completed then
            self.cache.taskState.completed[self.cache.task.index] = true
            self.cache.taskState.nextTaskIndex = self:AdvanceTaskSequence()
        end
    
        executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_COMPLETED:format(task.NAME or LANGUAGE.PRISON_TASK_DEFAULT_NAME, reduceMinutes))
    
        self:StopTask()
    
        return true
    end
    
    function Prison:StopTask()
        if not self.cache.task then
            return
        end
    
        local playerPed = PlayerPedId()
    
        executeAdapter('stopAnimation', playerPed)
        executeAdapter('setPrisonTaskMovement', playerPed, false)
    
        if self.cache.task.object then
            executeAdapter('deleteObject', self.cache.task.object)
        end
    
        if self.cache.task.blip then
            RemoveBlip(self.cache.task.blip)
        end
    
        self.cache.task = nil
    end
    
    function Prison:Insert(sentence, releaseTick)
        if self.cache.isActive then
            self.cache.sentence = tonumber(sentence) or self.cache.sentence or 1
            self.cache.releaseTick = tonumber(releaseTick) or self.cache.releaseTick or 0
            self.cache.lastShownSentence = nil
    
            showSentence(self.cache.sentence)
    
            return
        end
    
        self.cache.isActive = true
        self.cache.polyzone = PolyZone:Create(PRISON_CONFIG.COORDINATES.POLYZONE, { name = 'cc_prison' })
    
        self.cache.releaseTick = tonumber(releaseTick) or 0
        self.cache.sentence = tonumber(sentence) or 1
        self.cache.lastShownSentence = nil
        self.cache.taskState = {
            completed = {},
            nextTaskIndex = 1
        }
        self.cache.task = nil
    
        local playerPed = PlayerPedId()
    
        showSentence(self.cache.sentence)
    
        self.cache.lastShownSentence = self.cache.sentence
    
        executeAdapter('onPlayerEnteredPrison', playerPed)
    
        Citizen.CreateThread(function()
            self:CreateMainThread()
        end)
    end
    
    function Prison:CreateMainThread()
        while self.cache.isActive do
            local playerPed = PlayerPedId()
            local playerCoordinates = GetEntityCoords(playerPed)
    
            if not self.cache.polyzone:isPointInside(playerCoordinates) then
                if not self.cache.isOutside then
                    self.cache.isOutside = true
    
                    executeAdapter('notifyPlayer', LANGUAGE.PRISON_ESCAPE_ATTEMPT)
                end
    
                executeAdapter('onPlayerLeftPrisonArea', playerPed)
            else
                self.cache.isOutside = false
            end
    
            local isAlive = executeAdapter('isPlayerAlive', playerPed)
    
            if not isAlive then
                if not self.cache.isDead then
                    self.cache.isDead = true
    
                    executeAdapter('notifyPlayer', LANGUAGE.PRISON_DEATH)
                end
    
                executeAdapter('onPlayerDeathInPrison', playerPed)
            else
                self.cache.isDead = false
            end
    
            if self.cache.releaseTick and self.cache.releaseTick > 0 then
                local remainingSeconds = math.max(0, math.floor(self.cache.releaseTick))
                local remainingSentence = math.max(1, math.ceil(remainingSeconds / 60))
    
                if remainingSentence ~= self.cache.lastShownSentence then
                    self.cache.lastShownSentence = remainingSentence
    
                    showSentence(remainingSentence)
                end
            end
    
            for taskIndex, task in ipairs(PRISON_CONFIG.TASKS or {}) do
                if task.LOCATION and task.LOCATION.COORDINATES then
                    drawTaskMarker(task)
    
                    if not self.cache.task then
                        local nextTaskIndex = self:GetTaskSequenceIndex()
    
                        if taskIndex == nextTaskIndex then
                            local distance = getTaskDistance(task, playerCoordinates)
                            local zDifference = math.abs(playerCoordinates.z - task.LOCATION.COORDINATES.z)
    
                            if distance and distance <= 2.0 and zDifference <= 2.0 and IsControlJustReleased(0, 38) then
                                self:StartTask(taskIndex)
                            end
                        end
                    end
                end
            end
    
            if self.cache.task and self.cache.task.finishAt and GetGameTimer() >= self.cache.task.finishAt then
                self:CompleteTask()
            end
    
            Citizen.Wait(0)
        end
    end
    
    function Prison:Remove(isScaped)
        if self.cache.isActive then
            self.cache.isActive = false
        
            local playerPed = PlayerPedId()
    
            hideSentence()
    
            self:StopTask()
    
            if isScaped then
                executeAdapter('notifyPlayer', LANGUAGE.PRISON_ESCAPE_ATTEMPT)
                executeAdapter('onPlayerEscapedFromPrison', playerPed)
            else
                executeAdapter('notifyPlayer', LANGUAGE.PRISON_RELEASED)
                executeAdapter('onPlayerReleasedFromPrison', playerPed)
            end
    
            self.cache = {}
            self.cache.task = nil
        end
    end
    
    function Prison:IsActive()
        return not not self.cache.isActive
    end
    
end)
importModule('client/handlers/Prison')

createModule('client/web/Chat', function()
    RegisterNUICallback('sendChatMessage', function(data, callback)
        local messageContent = type(data) == 'table' and data.message or nil
    
        if type(messageContent) ~= 'string' or messageContent == '' then
            callback('Ok')
    
            return
        end
    
        apiServer.sendMessageInChat(messageContent)
    
        callback('Ok')
    end)
    
    RegisterNUICallback('getAllChatMessages', function(data, callback)
        local formattedChat = {}
        local chatEntries = apiServer.getChatMessages()
    
        for index, entries in ipairs(chatEntries) do
            local playerId, playerName, messageContent, avatarURL = table.unpack(entries)
    
            formattedChat[index] = {
                id = playerId,
                author = playerName, 
                message = messageContent, 
                avatarURL = avatarURL
            }
        end
    
        callback(formattedChat)
    end)
    
    function insertNewChatMessage(playerId, playerName, messageContent, avatarURL)
        SendNUIMessage({
            action = 'newChatMessage',
            data = {
                id = playerId,
                author = playerName,
                message = messageContent, 
                avatarURL = avatarURL
            }
        })
    end
    
    function updateAllChatMessages(chatEntries)
        local formattedChat = {}
    
        for index, entries in ipairs(chatEntries) do
            local playerId, playerName, messageContent, avatarURL = table.unpack(entries)
    
            formattedChat[index] = {
                id = playerId,
                author = playerName, 
                message = messageContent, 
                avatarURL = avatarURL
            }
        end
    
        SendNUIMessage({
            action = 'updateAllChatMessages',
            data = formattedChat
        })
    end
    
    RegisterNetEvent('cc_mdt:insertNewChatMessage', insertNewChatMessage)
    RegisterNetEvent('cc_mdt:updateAllChatMessages', updateAllChatMessages)
    
end)
importModule('client/web/Chat')

createModule('client/web/Communications', function()
    RegisterNUICallback('sendCommunicationMessage', function(data, callback)
        local messageContent = type(data) == 'table' and data.message or nil
    
        if type(messageContent) ~= 'string' or messageContent == '' then
            callback('Ok')
    
            return
        end
    
        apiServer.sendCommunicationMessage(messageContent)
    
        callback('Ok')
    end)
    
    RegisterNUICallback('getAllCommunications', function(data, callback)
        local formattedChat = {}
        local chatEntries = apiServer.getCommunications()
    
        for index, entries in ipairs(chatEntries) do
            local playerId, playerName, messageContent, avatarURL = table.unpack(entries)
    
            formattedChat[index] = {
                id = playerId,
                author = playerName, 
                message = messageContent, 
                avatarURL = avatarURL
            }
        end
    
        callback(formattedChat)
    end)
    
    function insertNewCommunicationMessage(playerId, playerName, messageContent, avatarURL)
        SendNUIMessage({
            action = 'newCommunicationMessage',
            data = {
                id = playerId,
                author = playerName,
                message = messageContent, 
                avatarURL = avatarURL
            }
        })
    end
    
    function updateAllCommunications(communicationEntries)
        local formattedChat = {}
    
        for index, entries in ipairs(communicationEntries) do
            local playerId, playerName, messageContent, avatarURL = table.unpack(entries)
    
            formattedChat[index] = {
                id = playerId,
                author = playerName, 
                message = messageContent,
                avatarURL = avatarURL
            }
        end
    
        SendNUIMessage({
            action = 'updateAllCommunications',
            data = formattedChat
        })
    end
    
    RegisterNetEvent('cc_mdt:insertNewCommunicationMessage', insertNewCommunicationMessage)
    RegisterNetEvent('cc_mdt:updateAllCommunications', updateAllCommunications)
    
end)
importModule('client/web/Communications')

createModule('client/web/Fines', function()
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
        local status, errorMessage = apiServer.applyVehicleFine(data.vehiclePlate, data.fines)
    
        callback({
            success = status == true,
            errorMessage = errorMessage
        })
    end)
    
end)
importModule('client/web/Fines')

createModule('client/web/Main', function()
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
    
    function updateUserData(playerId, playerName, policeRank, inService, avatarURL, canManageOfficers, policeOrganization, panelLogoURL, panelPrimaryColor)
        SendNUIMessage({
            action = 'updateUserData',
            data = {
                id = playerId,
                name = playerName, 
                policeRank = policeRank,
                avatarURL = avatarURL, 
                inService = inService, 
                canManageOfficers = canManageOfficers,
                organization = policeOrganization,
                panelLogoURL = panelLogoURL,
                panelPrimaryColor = panelPrimaryColor
            }
        })
    end
    
    RegisterNUICallback('removeFocus', function(data, callBack)
        SetNuiFocus(false, false)
    
        apiServer.playerClosedInterface()
    
        callBack({})
    end)
    
    RegisterNUICallback('nuiLoaded', function(data, callBack)
        callBack({})
    end)
    
    RegisterNUICallback('getServerLogo', function(data, callBack)
        callBack(GENERAL_CONFIG.SERVER_LOGO_URL or '')
    end)
    
    RegisterNUICallback('getUserData', function(data, callback)
        local playerEntries = apiServer.getPlayerData()
        local playerId, playerName, policeRanking, inService, avatarURL, canManageOfficers, policeOrganization, panelLogoURL, panelPrimaryColor = table.unpack(playerEntries)
    
        callback({
            id = playerId,
            name = playerName, 
            policeRank = policeRanking,
            avatarURL = avatarURL, 
            inService = inService, 
            canManageOfficers = canManageOfficers,
            organization = policeOrganization,
            panelLogoURL = panelLogoURL,
            panelPrimaryColor = panelPrimaryColor
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
    
    RegisterNetEvent('cc_mdt:updateUserData', updateUserData)
    
end)
importModule('client/web/Main')

createModule('client/web/Occurrences', function()
    RegisterNUICallback('getOccurrenceData', function(data, callback)
        local userData, vehiclesData, occurrencesData, vehicleFines
        local resultType, resultEntries, occurrencesEntries = apiServer.getOccurrenceFromSearch(data.search)
    
        if resultType == 'NOT_FOUND' then
            callback({
                errorMessage = LANGUAGE.OCCURRENCE_SEARCH_NOT_FOUND,
            })
    
            return
        end
    
        if resultType == 'USER' then
            local playerId, playerName, playerAvatarURL, playerAge, playerIdentity, playerFineValue = table.unpack(resultEntries)
    
            userData = {
                id = playerId,
                name = playerName,
                age = playerAge,
                identity = playerIdentity,
                avatarURL = playerAvatarURL, 
                fineValue = playerFineValue
            }
    
            occurrencesData = {}
    
            for index, entries in ipairs(occurrencesEntries) do
                local occurrenceId, occurrenceTitle, occurrenceCreatedAt, officerName, officerId, occurrenceFine, occurrenceStatus = table.unpack(entries)
    
                table.insert(occurrencesData, {
                    id = occurrenceId,
                    title = occurrenceTitle,
                    createdAt = occurrenceCreatedAt,
                    officer = {
                        name = officerName,
                        id = officerId,
                    },
                    fine = occurrenceFine,
                    status = occurrenceStatus,
                })
            end
        elseif resultType == 'VEHICLE' then
            local plate, model, isDetained, imageURL, ownerId, ownerName = table.unpack(resultEntries)
    
            vehiclesData = {
                plate = plate,
                model = model,
                isDetained = isDetained,
                imageURL = imageURL,
                owner = ownerId and ownerName and {
                    id = ownerId,
                    name = ownerName
                }
            }
    
            vehicleFines = {}
    
            for index, entries in ipairs(occurrencesEntries) do
                local fineId, fineDescription, createdAt, officerName, officerId, fineValue, fineStatus = table.unpack(entries)
    
                table.insert(vehicleFines, {
                    id = fineId,
                    title = fineDescription,
                    createdAt = createdAt,
                    officer = {
                        name = officerName,
                        id = officerId,
                    },
                    fine = fineValue,
                    status = fineStatus
                })
            end
        end
    
        callback({
            user = userData, 
            fines = vehicleFines, 
            vehicle = vehiclesData, 
            occurrences = occurrencesData
        })
    end)
    
    RegisterNUICallback('registerOccurrence', function(data, callback)
        local suspectId = data.suspect and data.suspect.id
        local suspectDescription = data.suspect and data.suspect.description
        
        local crimes = data.crimes or {}
        local attenuants = (data.modifiers and data.modifiers.attenuants) or {}
        local aggravants = (data.modifiers and data.modifiers.aggravants) or {}
    
        local success, errorMessage = apiServer.registerNewOccurrence(suspectId, suspectDescription, crimes, attenuants, aggravants, data.photo)
    
        callback({
            errorMessage = errorMessage
        })
    end)
end)
importModule('client/web/Occurrences')

createModule('client/web/Officers', function()
    RegisterNUICallback('deleteOfficer', function(data, callback)
        local status, errorMessage = apiServer.fireOfficer(data.officerId)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('promoteOfficer', function(data, callback)
        local status, errorMessage = apiServer.promoteOfficer(data.officerId)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('demoteOfficer', function(data, callback)
        local status, errorMessage = apiServer.demoteOfficer(data.officerId)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('hireOfficer', function(data, callback)
        local status, errorMessage = apiServer.hireOfficer(data.officerId)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('getOfficers', function(data, callback)
        local formattedOfficers = {}
        local officersEntries = apiServer.getServerOfficers()
    
        for index, entries in ipairs(officersEntries) do
            local playerId, playerName, policeRank, inService, playerCoords, avatarURL = table.unpack(entries)
    
            playerCoords = playerCoords or { 0, 0, 0 }
    
            formattedOfficers[index] = {
                id = tostring(playerId),
                name = playerName, 
                avatarURL = avatarURL,
                policeRank = policeRank,
                inService = inService,
                serviceTime = 0,
                coords = {
                    x = playerCoords[1] or playerCoords.x or 0,
                    y = playerCoords[2] or playerCoords.y or 0,
                    z = playerCoords[3] or playerCoords.z or 0
                }
            }
        end
    
        callback(formattedOfficers)
    end)
    
    RegisterNUICallback('getOfficersOnMap', function(data, callback)
        local formattedOfficersCoords = {}
        local officersCoordsEntries = apiServer.getOfficersCoordinates()
    
        for index, entries in ipairs(officersCoordsEntries) do
            local playerId, playerName, playerCoords, color = table.unpack(entries)
    
            formattedOfficersCoords[index] = {
                id = tostring(playerId), 
                name = playerName, 
                color = color, 
                coords = {
                    x = playerCoords[1],
                    y = playerCoords[2],
                    z = playerCoords[3]
                }
            }
        end
    
        callback(formattedOfficersCoords)
    end)
    
    function updateOfficersOnMap(officersCoordsEntries)
        local formattedOfficersCoords = {}
    
        for index, entries in ipairs(officersCoordsEntries) do
            local playerId, playerName, playerCoords, color = table.unpack(entries)
    
            formattedOfficersCoords[index] = {
                id = playerId, 
                name = playerName, 
                color = color, 
                coords = {
                    x = playerCoords[1],
                    y = playerCoords[2],
                    z = playerCoords[3]
                }
            }
        end
    
        SendNUIMessage({
            action = 'updateOfficersOnMap',
            data = formattedOfficersCoords
        })
    end
    
    RegisterNetEvent('cc_mdt:updateOfficersOnMap', updateOfficersOnMap)
    
end)
importModule('client/web/Officers')

createModule('client/web/Photo', function()
    RegisterNUICallback('setAvatarURL', function(data, callback)
        apiServer.updateAvatarURL(data.avatarURL)
    
        callback({})
    end)
    
    RegisterNUICallback('initAvatarPicture', function(data, callback)
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
    
        Citizen.CreateThread(function()
            local photoURL = executeAdapter('takePhoto', true, true)
                    
            setAvatarPicture(photoURL)
        end)
    
        callback({})
    end)
    
    function setAvatarPicture(avatarURL)
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        SendNUIMessage({
            action = 'setAvatarPictureForm',
            data = avatarURL
        })
    end
    
    RegisterNUICallback('initPhotoPicture', function(data, callback)
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
    
        Citizen.CreateThread(function()
            local photoURL = executeAdapter('takePhoto')
    
            setPictureForm(photoURL)
        end)
    
        callback({})
    end)
    
    function setPictureForm(photoURL)
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        SendNUIMessage({
            action = 'setPictureForm',
            data = photoURL
        })
    end
    
    RegisterNUICallback('initVehiclePicture', function(data, callback)
        SetNuiFocus(false, false)
        SetCursorLocation(0.5, 0.5)
    
        Citizen.CreateThread(function()
            local photoURL = executeAdapter('takePhoto')
    
            setVehiclePictureForm(photoURL)
        end)
    
        callback({})
    end)
    
    function setVehiclePictureForm(photoURL)
        SetNuiFocus(true, true)
        SetCursorLocation(0.5, 0.5)
        SendNUIMessage({
            action = 'setVehiclePictureForm',
            data = photoURL
        })
    end
end)
importModule('client/web/Photo')

createModule('client/web/Prison', function()
    function showSentence(sentence)
        SendNUIMessage({
            action = 'showSentence',
            data = {
                sentence = sentence
            }
        })
    end
    
    function hideSentence()
        SendNUIMessage({
            action = 'hideSentence',
            data = {}
        })
    end
    
end)
importModule('client/web/Prison')

createModule('client/web/Register', function()
    RegisterNUICallback('updateRegister', function(data, callback)
        local suspectId = data.suspect and data.suspect.id
        local status, resultEntries = apiServer.updateRegister(data.id, suspectId, data.crimes or {})
        
        if not status then
            return callback({ errorMessage = resultEntries })
        end
        
        local formattedCrimes = {}
        local playerId, suspectId, suspectDescription, isFinished, sentence, fine, bailAmount, crimes = table.unpack(resultEntries)
        
        for _, crimeId in ipairs(crimes) do
            table.insert(formattedCrimes, { id = crimeId })
        end
    
        callback({
            newData = {
                id = playerId,
                isFinished = isFinished,
                description = suspectDescription,
                sentence = sentence,
                fine = fine,
                bailAmount = bailAmount,
                crimes = formattedCrimes,
                suspect = {
                    id = suspectId
                }
            }
        })
    end)
    
    RegisterNUICallback('finishRegister', function(data, callback)
        local status, errorMessage = apiServer.finishRegister(data.id)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('deleteRegister', function(data, callback)
        local status, errorMessage = apiServer.deleteRegister(data.id)
    
        callback({
            errorMessage = errorMessage
        })
    end)
    
    RegisterNUICallback('getRegistersData', function(data, callback)
        local formattedRegisters = {}
        local registerEntries = apiServer.getServerRegisters()
    
        for index, entries in ipairs(registerEntries) do
            local registerId, officerId, officerName, suspectId, suspectName, suspectIdentity, crimes, description, sentence, fine, bailAmount, formattedDate, isFinished = table.unpack(entries)
    
            local formattedCrimes = {}
    
            for _, crimeId in ipairs(crimes) do
                table.insert(formattedCrimes, {
                    id = crimeId
                })
            end
    
            formattedRegisters[index] = {
                id = registerId,
                police = {
                    name = officerName,
                    id = officerId,
                },
                formattedDate = formattedDate,
                suspect = {
                    name = suspectName,
                    id = suspectId,
                    identity = suspectIdentity,
                },
                isFinished = isFinished, -- Opcional
                crimes = formattedCrimes,
                description = description,
                sentence = sentence,
                fine = fine,
                bailAmount = bailAmount, -- Opcional
            }
        end
    
        callback(formattedRegisters)
    end)
end)
importModule('client/web/Register')

createModule('client/web/Reports', function()
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
    
end)
importModule('client/web/Reports')
