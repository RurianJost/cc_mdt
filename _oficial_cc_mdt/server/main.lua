apiClient = Tunnel.getInterface('cc_mdt')

api = {}
Tunnel.bindInterface('cc_mdt', api)

if not LPH_OBFUSCATED then
    __isAuth__ = true

    LPH_NO_VIRTUALIZE = function(...) 
        return ... 
    end
end