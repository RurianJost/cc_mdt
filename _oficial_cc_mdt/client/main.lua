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

-- _RegisterNUICallback = RegisterNUICallback 
-- function RegisterNUICallback(name, handler)
--     local _handler = function(a, b)
--         print('[CALLBACK]', name, json.encode(a, { indent = true }))
        
--         local _b = function(c)
--             print(json.encode(c, { indent = true }))
            
--             return b(c)
--         end 

--         return handler(a, _b)
--     end 

--     return _RegisterNUICallback(name, _handler)
-- end

-- _SendNUIMessage = SendNUIMessage
-- function SendNUIMessage(message)
--     print('[MESSAGE]', json.encode(message, { indent = true }))
    
--     return _SendNUIMessage(message)
-- end

executeAdapter('registerHandler', function()
    local canOpenPainel = apiServer.canOpenPainel()

    if canOpenPainel then 
        openInterface()
    end
end)