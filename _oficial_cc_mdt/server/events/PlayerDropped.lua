AddEventHandler('playerDropped', function()
    local playerSource = source

    Prison:OnPlayerDropped(playerSource)
    Interface:OnPlayerClose(playerSource)
end)
