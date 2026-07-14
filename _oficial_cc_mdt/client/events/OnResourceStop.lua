AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then 
        return 
    end 
    
end)