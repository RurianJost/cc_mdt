_G.Animation = {}

function Animation:Start(dictionary, name)
    self:Stop()

    Citizen.CreateThread(LPH_NO_VIRTUALIZE(function()
        RequestAnimDict(dictionary)

        while not HasAnimDictLoaded(dictionary) do
            RequestAnimDict(dictionary)

            Citizen.Wait(10)
        end

        if HasAnimDictLoaded(dictionary) then
            local playerPed = PlayerPedId()
            
            TaskPlayAnim(playerPed, dictionary, name, 3.0, 3.0, -1, 1, 0, 0, 0, 0)
        end
    end))
end

function Animation:Stop()
    local playerPed = PlayerPedId()

    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
end