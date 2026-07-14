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
