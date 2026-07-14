_G.ProfilePhotos = {
    cache = {}
}

function ProfilePhotos:Setup()
    self.cache = executeAdapter('getDatabaseProfilePhotos')
end

function ProfilePhotos:SetPhoto(playerId, photoUrl)
    self.cache[playerId] = photoUrl

    executeAdapter('updatePlayerProfilePhoto', playerId, photoUrl)
end

function ProfilePhotos:GetPhoto(playerId)
    if playerId then
        return self.cache[playerId] or ''
    end

    return self.cache
end