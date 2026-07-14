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
    'registerHandler', 
    function(handler)
        RegisterCommand('mdt', handler)
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
        AddTextComponentString('Officer Location')
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
        AddTextComponentString('Report Location')
        EndTextCommandSetBlipName(blip)

        Citizen.SetTimeout(30000, function()
            RemoveBlip(blip)
        end)
    end, 
    { priority = NATIVES_PRIORITY }
)

