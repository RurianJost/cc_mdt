replaceAdapter(
    'onPlayerAniming', 
    function(toogle)
        LocalPlayer.state:set('Cancel', toogle, true)
        LocalPlayer.state:set('Commands', toogle, true)

        TriggerEvent('cancelando', toogle)
    end
)

local animation = {
    active = false,
    dictionary = nil,
    name = nil
}

replaceAdapter(
    'startAnimation', 
    function(playerPed, dictionary, name, allowWalk)
        executeAdapter('stopAnimation', playerPed)
        
        animation = {
            active = true,
            dictionary = dictionary,
            name = name,
            allowWalk = allowWalk
        }

        Citizen.CreateThread(function()
            RequestAnimDict(dictionary)

            while not HasAnimDictLoaded(dictionary) do
                RequestAnimDict(dictionary)
                Citizen.Wait(10)
            end

            if HasAnimDictLoaded(dictionary) then
                local animationFlags = allowWalk and 49 or 1

                TaskPlayAnim(playerPed, dictionary, name, 3.0, 3.0, -1, animationFlags, 0, 0, 0, 0)
                SetPedKeepTask(playerPed, true)
            end
        end)
    end
)

replaceAdapter(
    'setPrisonTaskMovement',
    function(playerPed, allowWalk)
        LocalPlayer.state:set('PrisonTaskWalk', allowWalk, true)
    end
)


replaceAdapter(
    'stopAnimation', 
    function(playerPed)
        animation.active = false

        ClearPedTasks(playerPed)
        ClearPedSecondaryTask(playerPed)

        animation = {}
    end
)

Citizen.CreateThread(function()
	while true do
		local sleepTime = 1000

        if animation.active then
            sleepTime = 0

			DisableControlAction(1, 16, true)
			DisableControlAction(1, 17, true)
			DisableControlAction(1, 24, true)
			DisableControlAction(1, 25, true)
			DisableControlAction(1, 21, true)

            if not animation.allowWalk then
                DisableControlAction(1, 30, true)
                DisableControlAction(1, 31, true)
                DisableControlAction(1, 32, true)
                DisableControlAction(1, 33, true)
                DisableControlAction(1, 34, true)
                DisableControlAction(1, 35, true)
            end

            local playerPed = PlayerPedId()

            if not IsEntityPlayingAnim(playerPed, animation.dictionary, animation.name, 3) then
                TaskPlayAnim(playerPed, animation.dictionary, animation.name, 3.0, 3.0, -1, animation.allowWalk and 49 or 1, 0, 0, 0, 0)
            end
        end
		
		Citizen.Wait(sleepTime)
	end
end)