_G.Headshot = {
    cache = {}
}

function Headshot:GetPedHeadshot()
    if self.cache.id ~= nil and IsPedheadshotValid(self.cache.id) and IsPedheadshotReady(self.cache.id) then
        return self.cache.txdString
    else
        for i = 1, 32 do 
            UnregisterPedheadshot(i)
        end
    
        local playerPed = PlayerPedId()
        local id = RegisterPedheadshotTransparent(playerPed)
        local tolerance = GetGameTimer() + 500
        
        while not IsPedheadshotReady(id) and GetGameTimer() < tolerance do 
            Citizen.Wait(10)
        end 
        
        if IsPedheadshotValid(id) then 
            local txdString = GetPedheadshotTxdString(id)

            if txdString then
                self.cache.id = id
                self.cache.txdString = txdString

                return self.cache.txdString
            end
        end
    end
end