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