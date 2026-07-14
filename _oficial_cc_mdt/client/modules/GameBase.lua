_G.GameUtils = {}

function GameUtils:ScreenFade(cooldownTime, callbackBetweenFade)
    DoScreenFadeOut(cooldownTime)

    Citizen.Wait(cooldownTime)

    callbackBetweenFade()

    DoScreenFadeIn(cooldownTime)
end

GameUtils.EntityBetweenVectors = LPH_NO_VIRTUALIZE(function(self, entity, _vector, _distance)
	local entityCoords = GetEntityCoords(entity)
	local distance = #(entityCoords - _vector)

	return distance <= _distance, distance
end)

GameUtils.BlockShootingThisFrame = LPH_NO_VIRTUALIZE(function(self)
	DisablePlayerFiring(PlayerId())

	HudWeaponWheelIgnoreSelection()

	DisableControlAction(1, 24, true)
	DisableControlAction(1, 25, true)
	DisableControlAction(1, 37, true)
	DisableControlAction(1, 45, true)
	DisableControlAction(1, 47, true)
	DisableControlAction(1, 58, true)
	DisableControlAction(1, 80, true)
	DisableControlAction(1, 106, true)
	DisableControlAction(1, 140, true)
	DisableControlAction(1, 141, true)
	DisableControlAction(1, 142, true)
	DisableControlAction(1, 143, true)
	DisableControlAction(1, 250, true)
	DisableControlAction(1, 263, true)
	DisableControlAction(1, 310, true)
end)

GameUtils.DrawText = LPH_NO_VIRTUALIZE(function(self, text, font, x, y, scale)
	SetTextFont(font)
	SetTextScale(scale, scale)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(x, y)
end)

GameUtils.DrawText3Ds = LPH_NO_VIRTUALIZE(function(self, coordinates, text)
	local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coordinates.x, coordinates.y, coordinates.z)
	
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 235)
		SetTextEntry('STRING')
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
		
		local factor = (string.len(text)) / 350
		DrawRect(_x, _y + 0.0125, 0.005 + factor, 0.04, 0, 0, 0, 145)
	end
end)