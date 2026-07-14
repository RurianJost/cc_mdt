function api.prisonPlayer(sentence, releaseTick)
    Prison:Insert(sentence, releaseTick)
end

function api.removePrisonPlayer(isScaped)
    Prison:Remove(isScaped)
end

function api.updatePrisonSentence(sentence, releaseTick)
    Prison:UpdateSentence(sentence, releaseTick)
end

function api.getPlayerClothes()
    local playerPed = PlayerPedId()

    return executeAdapter('getPlayerClothes', playerPed)
end

function api.setPlayerClothes(clothesToSet)
    local playerPed = PlayerPedId()

    executeAdapter('setClothesOnPlayer', playerPed, clothesToSet)
end
