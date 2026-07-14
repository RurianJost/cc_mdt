local SCRIPT_PRIORITY    = 300
local FRAMEWORK_PRIORITY = 200
local NATIVES_PRIORITY   = 100

registerFramework(
    'vrp', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' then 
            return false
        end 
        
        return not not framework.clientSide.getNearestPlayers(0)
    end, 
    function()
        local vRP, vRPserver = Proxy.getInterface('vRP')

        return function()
            return { clientSide = vRP, serverSide = vRPserver }
        end 
    end 
)

registerFramework(
    'creativeV4', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' then 
            return false
        end 

        return not not framework.clientSide.nearestPlayersBlips()
    end, 
    function()
        local vRP, vRPserver = Proxy.getInterface('vRP')

        return function()
            return { clientSide = vRP, serverSide = vRPserver }
        end 
    end 
)

registerFramework(
    'creativeV5', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' then 
            return false
        end 

        return not not framework.clientSide.nearestPlayers(0)
    end, 
    function()
        local vRP, vRPserver = Proxy.getInterface('vRP')

        return function()
            return { clientSide = vRP, serverSide = vRPserver }
        end 
    end 
)

registerFramework(
    'creativeNW', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' then 
            return false
        end 

        return not not framework.clientSide.ClosestPeds(0)
    end, 
    function()
        local vRP, vRPserver = Proxy.getInterface('vRP')

        return function()
            return { clientSide = vRP, serverSide = vRPserver }
        end 
    end 
)

registerFramework(
    'esx_legacy', 
    function(framework)
        if not framework then 
            return false 
        end 

        return GetResourceState('es_extended') == 'started'
    end, 
    function()
        local isSuccess, ESX = pcall(function()
            return exports.es_extended:getSharedObject()
        end) 

        return function()
            if isSuccess then
               return { clientSide = ESX }
            end 
        end 
    end  
)

registerFramework(
    'nyo_fw', 
    function(framework)
        if not framework then 
            return false 
        end 

        return GetResourceState('nyo_modules') == 'started'
    end, 
    function()
        return function()
            return { clientSide = exports.nyo_modules }
        end 
    end  
)

registerFramework(
    'qbus', 
    function(framework)
        return GetResourceState('qb-core') == 'started' and framework
    end, 
    function()
        return function()
            local hasCore = GetResourceState('qb-core') == 'started'
            local frameworkFunctions = {}

            if hasCore then 
                frameworkFunctions.serverSide = exports['qb-core']:GetCoreObject()

                RegisterNetEvent('QBCore:Client:UpdateObject', function()
                    frameworkFunctions.serverSide = exports['qb-core']:GetCoreObject() 
                end)
            end

            return frameworkFunctions
        end 
    end 
)

registerAdapter(
    'notifyPlayer',
    function(message)
        TriggerEvent('Notify', 'warn', message, 10000)
    end,
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'registerHandler', 
    function(handler)
        RegisterCommand('mdt', handler)
    end, 
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'onPlayerAcceptReport', 
    function(reportId, createdBy, description, coords)
        executeAdapter('notifyPlayer', LANGUAGE.REPORT_ACCEPTED_NOTIFY:format(reportId, description, createdBy))
        executeAdapter('createReportBlipLocation', {
            x = coords[1],
            y = coords[2],
            z = coords[3]
        })
    end, 
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'createOfficerBlipLocation', 
    function(coordinates)
        local blip = AddBlipForCoord(coordinates.x, coordinates.y, coordinates.z)

        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.2)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(LANGUAGE.OFFICER_LOCATION_BLIP)
        EndTextCommandSetBlipName(blip)

        Citizen.SetTimeout(30000, function()
            RemoveBlip(blip)
        end)
    end, 
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'createReportBlipLocation', 
    function(coordinates)
        local blip = AddBlipForCoord(coordinates.x, coordinates.y, coordinates.z)

        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.2)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(LANGUAGE.REPORT_LOCATION_BLIP)
        EndTextCommandSetBlipName(blip)

        Citizen.SetTimeout(30000, function()
            RemoveBlip(blip)
        end)
    end, 
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'createPrisonTaskBlipLocation', 
    function(coordinates, blipData)
        local blip = AddBlipForCoord(coordinates.x, coordinates.y, coordinates.z)
        local sprite = blipData and blipData.SPRITE or 1
        local colour = blipData and blipData.COLOUR or 3
        local scale = blipData and blipData.SCALE or 1.0
        local label = blipData and blipData.LABEL or LANGUAGE.PRISON_TASK_DEFAULT_BLIP

        if not DoesBlipExist(blip) then
            return nil
        end

        SetBlipSprite(blip, sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, scale)
        SetBlipColour(blip, colour)
        SetBlipAsShortRange(blip, true)

        if blipData and blipData.ROUTE then
            SetBlipRoute(blip, true)

            if blipData.ROUTE_COLOUR then
                SetBlipRouteColour(blip, blipData.ROUTE_COLOUR)
            end
        end

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)

        if blipData and blipData.DURATION_SECONDS then
            Citizen.SetTimeout(blipData.DURATION_SECONDS * 1000, function()
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end)
        end

        return blip
    end, 
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'createPrisonTaskAnimation', 
    function(playerPed, animationData)
        if not animationData or not animationData.DICT or not animationData.NAME then
            return false
        end

        executeAdapter('startAnimation', playerPed, animationData.DICT, animationData.NAME, animationData.ALLOW_WALK)

        return true
    end, 
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'createPrisonTaskObject', 
    function(playerPed, objectData)
        if not objectData or not objectData.MODEL then
            return false
        end

        local objectModel = GetHashKey(objectData.MODEL)

        if IsModelInCdimage(objectModel) and IsModelValid(objectModel) then
            RequestModel(objectModel)

            while not HasModelLoaded(objectModel) do
                Citizen.Wait(1)
            end

            local boneIndex = GetPedBoneIndex(playerPed, objectData.BONE or 28422)
            local position = objectData.POSITION or vector3(0.0, 0.0, 0.0)
            local rotation = objectData.ROTATION or vector3(0.0, 0.0, 0.0)
            local coordinates = GetEntityCoords(playerPed)
            local object = CreateObject(objectModel, coordinates.x, coordinates.y, coordinates.z, false, true, true)

            AttachEntityToEntity(object, playerPed, boneIndex, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, false, false, false, false, 2, true)

            SetEntityAsMissionEntity(object, true, true)
            SetModelAsNoLongerNeeded(objectModel)

            return object
        end

        return false
    end, 
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'createAnimationObject', 
    function(playerPed, objectName, handBone)
        local objectModel = GetHashKey(objectName)

        if IsModelInCdimage(objectModel) and IsModelValid(objectModel) then
            RequestModel(objectModel)

            while not HasModelLoaded(objectModel) do
                Citizen.Wait(1)
            end

            local boneIndex = GetPedBoneIndex(playerPed, handBone)
            local coordinates = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.0, -5.0)
            local object = CreateObject(objectModel, coordinates.x, coordinates.y, coordinates.z, false, true, true)

            AttachEntityToEntity(object, playerPed, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

            SetEntityAsMissionEntity(object, true, true)
            SetModelAsNoLongerNeeded(objectModel)

            return object
        end

        return false
    end, 
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'deleteObject', 
    function(object)
        while DoesEntityExist(object) do 
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
        end 
    end, 
    { priority = SCRIPT_PRIORITY }
)

function CellFrontCamActivate(activate)
    return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

registerAdapter(
    'takePhoto',
    function(usePhoneCam, frontCam)
        local response = promise.new()

        local playerPed = PlayerPedId()

        local photoURL = nil
        local isActive = true
        local object = nil
        local cam = nil

        local fovMax = 70.0
        local fovMin = 5.0
        local fov = (fovMax + fovMin) * 0.5

        local function checkInputRotation(currentCam, zoomValue)
            local rightAxisX = GetDisabledControlNormal(0, 220)
            local rightAxisY = GetDisabledControlNormal(0, 221)
            local rotation = GetCamRot(currentCam, 2)

            if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
                local newZ = rotation.z + rightAxisX * -1.0 * 8.0 * (zoomValue + 0.1)
                local newX = math.max(
                    math.min(20.0, rotation.x + rightAxisY * -1.0 * 8.0 * (zoomValue + 0.1)),
                    -89.5
                )

                SetCamRot(currentCam, newX, 0.0, newZ, 2)
            end
        end

        local function handleZoom(currentCam)
            if IsControlJustPressed(1, 241) then
                fov = math.max(fov - 10.0, fovMin)
            end

            if IsControlJustPressed(1, 242) then
                fov = math.min(fov + 10.0, fovMax)
            end

            local currentFov = GetCamFov(currentCam)

            if math.abs(fov - currentFov) < 0.1 then
                fov = currentFov
            end

            SetCamFov(currentCam, currentFov + (fov - currentFov) * 0.05)
        end

        executeAdapter('onPlayerAniming', true)

        if usePhoneCam then
            executeAdapter('stopAnimation', playerPed)

            if deleteObject then
                deleteObject()
            end

            if stopAnim then
                stopAnim(false)
            end

            CreateMobilePhone(10)
            CellCamActivate(true, true)
            CellFrontCamActivate(frontCam)
        else
            cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)

            AttachCamToEntity(cam, playerPed, 0.0, 0.0, 1.0, true)
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(playerPed), 2)
            SetCamFov(cam, fov)
            RenderScriptCams(true, false, 0, true, false)

            executeAdapter('startAnimation', playerPed, 'amb@world_human_paparazzi@male@base', 'base')

            object = executeAdapter('createAnimationObject', playerPed, 'prop_pap_camera_01', 28422)
        end

        Wait(1000)

        while isActive do
            Citizen.Wait(0)

            if cam then
                local zoomValue = (1.0 / (fovMax - fovMin)) * (fov - fovMin)

                checkInputRotation(cam, zoomValue)
                handleZoom(cam)
            end

            if IsControlJustPressed(1, 177) then
                photoURL = nil
                isActive = false
            elseif IsDisabledControlJustReleased(1, 18) then
                if GetResourceState('screencapture') == 'started' then
                    exports['screencapture']:requestScreenshot({ encoding = 'webp' }, function(data)
                        response:resolve(data)
                    end)
                elseif GetResourceState('screenshot-basic') == 'started' then
                    exports['screenshot-basic']:requestScreenshot({ encoding = 'webp' }, function(url)
                        response:resolve(url)
                    end)
                else
                    response:resolve(nil)
                end

                photoURL = Citizen.Await(response)
                isActive = false
            end

            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(19)
            HideHudAndRadarThisFrame()
        end

        fov = (fovMax + fovMin) * 0.5

        if usePhoneCam then
            DestroyMobilePhone()
            CellCamActivate(false, false)

            if carryObject then
                carryObject('amb@code_human_in_bus_passenger_idles@female@tablet@idle_a', 'idle_b', 'prop_cs_tablet', 49, 28422)
            end
        end

        if cam then
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)
        end

        SetNightvision(false)
        SetSeethrough(false)

        executeAdapter('stopAnimation', playerPed)
        executeAdapter('onPlayerAniming', false)

        if object then
            executeAdapter('deleteObject', object)
        end

        response = nil

        return photoURL
    end,
    { priority = NATIVES_PRIORITY }
)

local BASE_CLOTHES = {
    { TYPE = 'PROP', NAME = 'HAT', INDEX = 0 },
    { TYPE = 'PROP', NAME = 'GLASS', INDEX = 1 },
    { TYPE = 'PROP', NAME = 'EAR', INDEX = 2 },
    { TYPE = 'PROP', NAME = 'WATCH', INDEX = 6 },
    { TYPE = 'PROP', NAME = 'BRACELET', INDEX = 7 },

    { TYPE = 'COMPONENT', NAME = 'MASK', INDEX = 1 },
    { TYPE = 'COMPONENT', NAME = 'ARMS', INDEX = 3 },
    { TYPE = 'COMPONENT', NAME = 'PANTS', INDEX = 4 },
    { TYPE = 'COMPONENT', NAME = 'BACKPACK', INDEX = 5 },
    { TYPE = 'COMPONENT', NAME = 'SHOES', INDEX = 6 },
    { TYPE = 'COMPONENT', NAME = 'ACCESSORY', INDEX = 7 },
    { TYPE = 'COMPONENT', NAME = 'TSHIRT', INDEX = 8 },
    { TYPE = 'COMPONENT', NAME = 'VEST', INDEX = 9 },
    { TYPE = 'COMPONENT', NAME = 'DECALS', INDEX = 10 },
    { TYPE = 'COMPONENT', NAME = 'TORSO', INDEX = 11 }
}

registerAdapter(
    'getPlayerClothes',
    function(playerPed)
        local playerClothes = {}

        for _, clothes in ipairs(BASE_CLOTHES) do
            if clothes.TYPE == 'PROP' then
                playerClothes[clothes.NAME] = {
                    ITEM = GetPedPropIndex(playerPed, clothes.INDEX),
                    TEXTURE = math.max(GetPedPropTextureIndex(playerPed, clothes.INDEX), 0)
                }
            else
                playerClothes[clothes.NAME] = {
                    ITEM = GetPedDrawableVariation(playerPed, clothes.INDEX),
                    TEXTURE = GetPedTextureVariation(playerPed, clothes.INDEX)
                }
            end
        end
    
        return playerClothes
    end, 
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'setClothesOnPlayer',
    function(playerPed, clothesToSet)
        ResetPedStrafeClipset(playerPed)
        ResetPedMovementClipset(playerPed, 0.25)

        for _, clothes in ipairs(BASE_CLOTHES) do
            local clotheName = clothes.NAME
    
            if clothesToSet[clotheName] then
                local clotheIndex = clothes.INDEX
                local clotheItem = clothesToSet[clotheName].ITEM
                local clotheTexture = clothesToSet[clotheName].TEXTURE
    
                if clothes.TYPE == 'COMPONENT' then
                    SetPedComponentVariation(playerPed, clotheIndex, clotheItem, clotheTexture, 1)
                else
                    if clotheItem ~= -1 and clotheItem ~= 0 then
                        SetPedPropIndex(playerPed, clotheIndex, clotheItem, clotheTexture, 1)
                    else
                        ClearPedProp(playerPed, clotheIndex)
                    end
                end
            end
        end
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'isPlayerAlive',
    function(playerPed)
        return GetEntityHealth(playerPed) > 100
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'onPlayerEnteredPrison',
    function(playerPed)
        SetEntityCoords(playerPed, PRISON_CONFIG.COORDINATES.CENTER)
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'onPlayerReleasedFromPrison',
    function(playerPed)
        SetEntityCoords(playerPed, PRISON_CONFIG.COORDINATES.EXIT)
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'onPlayerEscapedFromPrison',
    function(playerPed)
        
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'onPlayerLeftPrisonArea',
    function(playerPed)
        SetEntityCoords(playerPed, PRISON_CONFIG.COORDINATES.CENTER)
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'onPlayerDeathInPrison',
    function(playerPed)
        executeAdapter('ressurectPed', playerPed)
    end,
    { priority = NATIVES_PRIORITY }
)

registerAdapter(
    'ressurectPed',
    function(playerPed)
        local pedCoords = GetEntityCoords(playerPed)
        local pedHeading = GetEntityHeading(playerPed)

        NetworkResurrectLocalPlayer(pedCoords, pedHeading, true, false)
        
        ClearPedBloodDamage(playerPed)
        ClearPedTasks(playerPed)
        ClearPedSecondaryTask(playerPed)

        local maxHealth = GetEntityMaxHealth(playerPed)
        
        SetEntityHealth(playerPed, maxHealth)
    end,
    { priority = NATIVES_PRIORITY }
)
