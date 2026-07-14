apiClient = Tunnel.getInterface('RKG_Store')

api = {}
Tunnel.bindInterface('RKG_Store', api)

if not LPH_OBFUSCATED then
    __isAuth__ = true

    LPH_NO_VIRTUALIZE = function(...) 
        return ... 
    end
end