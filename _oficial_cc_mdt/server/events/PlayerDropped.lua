AddEventHandler('playerDropped', function()
    local playerSource = source
    
    Interface:OnPlayerClose(playerSource)
end)