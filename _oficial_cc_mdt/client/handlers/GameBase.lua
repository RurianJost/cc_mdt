_G.GameBase = {
    cache = {}
}

function GameBase:Insert()
    self.cache.active = true
end

function GameBase:Remove()
    self.cache.active = false

    self.cache = {}
end

function GameBase:IsActive()
    return not not self.cache.active
end