_G.Interface = {
    cache = {}
}

function Interface:OnPlayerOpen(playerSource)
    table.insert(self.cache, playerSource)
end

function Interface:OnPlayerClose(playerSource)
    for i, v in ipairs(self.cache) do
        if v == playerSource then
            table.remove(self.cache, i)

            break
        end
    end
end

function Interface:IsPlayerInterfaceOpen(searchSource)
    for _, playerSource in ipairs(self.cache) do
        if playerSource == searchSource then
            return true
        end
    end

    return false
end

function Interface:GetAllOpenInterfaces()
    return self.cache
end