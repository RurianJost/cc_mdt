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