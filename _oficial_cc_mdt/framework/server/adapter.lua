local SCRIPT_PRIORITY    = 300
local FRAMEWORK_PRIORITY = 200
local NATIVES_PRIORITY   = 100

local function hasDatabaseTable(tableName)
    return executeAdapter('querySync', 'SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ? AND TABLE_SCHEMA = DATABASE();', { tableName })[1]
end 

local function await(handler)
    local response = promise.new()

    handler(function(...)
        response:resolve(...)
    end)

    return Citizen.Await(response)
end

local WRAPPERS_API = {
    {
        script = 'oxmysql',
        execute = 'query',
        fetch = 'query'
    },
    {
        script = 'ghmattimysql',
        execute = 'execute',
        fetch = 'execute'
    },
    {
        script = 'GHMattiMySQL',
        execute = 'QueryResultAsync',
        fetch = 'QueryResultAsync'
    },
    {
        script = 'mysql-async',
        execute = 'mysql_execute',
        fetch = 'mysql_fetch_all'
    }
}

for _, api in ipairs(WRAPPERS_API) do
    local canUse = getScriptStartedChecker(api.script)

    registerAdapter(
        'executeSync',
        function(consult, parameters)
            return await(function(resolvePromise)
                exports[api.script][api.execute](exports[api.script], consult, parameters or {}, resolvePromise)
            end)
        end,
        { canExecute = canUse, priority = SCRIPT_PRIORITY }
    )

    registerAdapter(
        'querySync',
        function(consult, parameters)
            return await(function(resolvePromise)
                exports[api.script][api.fetch](exports[api.script], consult, parameters or {}, resolvePromise)
            end)
        end,
        { canExecute = canUse, priority = SCRIPT_PRIORITY }
    )

    registerAdapter(
        'executeAsync',
        function(consult, parameters)
            exports[api.script][api.execute](exports[api.script], consult, parameters or {})
        end,
        { canExecute = canUse, priority = SCRIPT_PRIORITY }
    )
end

registerAdapter(
    'createDatabaseTables',
    function()
        executeAdapter('executeSync', [[
            CREATE TABLE IF NOT EXISTS `cc_mdt_ocurrences` (
                `id` INT(11) NOT NULL AUTO_INCREMENT,
                `officer_id` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
                `suspect_id` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
                `suspect_description` TEXT NOT NULL COLLATE 'latin1_swedish_ci',
                `crimes` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                `attenuants` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                `aggravants` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                `photo_url` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                `payload` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                `is_finished` TINYINT(1) NOT NULL DEFAULT '0',
                `created_at` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE,
                CONSTRAINT `payload` CHECK (json_valid(`payload`)),
                CONSTRAINT `crimes` CHECK (json_valid(`crimes`)),
                CONSTRAINT `attenuants` CHECK (json_valid(`attenuants`)),
                CONSTRAINT `aggravants` CHECK (json_valid(`aggravants`))
            )
            COLLATE='latin1_swedish_ci'
            ENGINE=InnoDB
            ;
        ]])
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getDatabaseOcurrences',
    function()
        local formattedOcurrences = {}
        local consultResult = executeAdapter('executeSync', 'SELECT * FROM cc_mdt_ocurrences', {})
    
        for _, row in ipairs(consultResult) do
            formattedOcurrences[row.id] = {
                id = row.id,
                officerId = row.officer_id,
                suspectId = row.suspect_id,
                suspectDescription = row.suspect_description,
                crimes = json.decode(row.crimes),
                attenuants = json.decode(row.attenuants),
                aggravants = json.decode(row.aggravants),
                payload = json.decode(row.payload),
                isFinished = row.is_finished == 1,
                photoURL = row.photo_url,
                createdAt = row.created_at
            }
        end

        return formattedOcurrences
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerFramework(
    'vrp', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 
        
        local function tryGetGroups() 
            return require('vrp', 'cfg/groups')
        end 
        
        local hasGroups = pcall(tryGetGroups)
    
        return not not framework.serverSide.getUsers() and hasGroups
    end, 
    function()
        local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP')

        return function()
            return { clientSide = vRPclient, serverSide = vRP }
        end 
    end 
)

registerFramework(
    'creativeV4', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 
    
        return hasDatabaseTable('vrp_infos')
    end, 
    function()
        local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP')

        return function()
            return { clientSide = vRPclient, serverSide = vRP }
        end 
    end 
)

registerFramework(
    'creativeV5', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 
    
        return hasDatabaseTable('summerz_accounts')
    end, 
    function()
        local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP')

        return function()
            return { clientSide = vRPclient, serverSide = vRP }
        end 
    end 
)

registerFramework(
    'creativeNW', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 
    
        local function tryGetNative() 
            return require('vrp', 'config/Native')
        end 
        
        local hasNative = pcall(tryGetNative)
    
        return not not framework.serverSide.Players() and hasNative
    end, 
    function()
        local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP')

        return function()
            return { clientSide = vRPclient, serverSide = vRP }
        end 
    end 
)

registerFramework(
    'snt-base', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 
    
        return hasDatabaseTable('snt_accounts')
    end, 
    function()
        local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP')

        return function()
            return { clientSide = vRPclient, serverSide = vRP }
        end 
    end 
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.getUserId(source)
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.getUserId(source)
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.getUserId(source)
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.Passport(source)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.getCurrentCharacter(source)
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.getUserSource(playerId)
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.getUserSource(playerId)
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.userSource(playerId)
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.Source(playerId)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.getCharacterSource(playerId)
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hasPlayerPermission',
    function(source, permission)
        local playerId = executeAdapter('getPlayerId', source)

        if type(permission) == 'table' then
            for _, permissionName in ipairs(permission) do
                local hasPermission = frameworkFunctions.serverSide.hasPermission(playerId, permissionName) 

                if hasPermission then
                    return true
                end
            end
        else
            return frameworkFunctions.serverSide.hasPermission(playerId, permission) 
        end
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hasPlayerPermission',
    function(source, permission)
        local playerId = executeAdapter('getPlayerId', source)

        if type(permission) == 'table' then
            for _, permissionName in ipairs(permission) do
                local hasPermission = frameworkFunctions.serverSide.hasPermission(playerId, permissionName) 

                if hasPermission then
                    return true
                end
            end
        else
            return frameworkFunctions.serverSide.hasPermission(playerId, permission) 
        end
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hasPlayerPermission',
    function(source, permission)
        local playerId = executeAdapter('getPlayerId', source)

        if type(permission) == 'table' then
            for _, permissionName in ipairs(permission) do
                local hasPermission = frameworkFunctions.serverSide.hasPermission(playerId, permissionName) 

                if hasPermission then
                    return true
                end
            end
        else
            return frameworkFunctions.serverSide.hasPermission(playerId, permission) 
        end
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hasPlayerPermission',
    function(source, permission)
        local playerId = executeAdapter('getPlayerId', source)

        if type(permission) == 'table' then
            for _, permissionName in ipairs(permission) do
                local hasPermission = frameworkFunctions.serverSide.HasPermission(playerId, permissionName) 

                if hasPermission then
                    return true
                end
            end
        else
            return frameworkFunctions.serverSide.HasPermission(playerId, permission) 
        end
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hasPlayerPermission',
    function(source, permission)
        local playerId = executeAdapter('getPlayerId', source)

        if type(permission) == 'table' then
            for _, permissionName in ipairs(permission) do
                local hasPermission = frameworkFunctions.serverSide.hasPermission(playerId, permissionName) 

                if hasPermission then
                    return true
                end
            end
        else
            return frameworkFunctions.serverSide.hasPermission(playerId, permission) 
        end
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return tostring(identity.name or 'Indefinido').. ' '.. tostring(identity.firstname or 'Indefinido')
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return tostring(identity.name or 'Indefinido').. ' '.. tostring(identity.firstname or 'Indefinido')
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.userIdentity(playerId) or {}
        
        return tostring(identity.name or 'Indefinido').. ' '.. tostring(identity.name2 or 'Indefinido')
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}
        
        return tostring(identity.name or identity.Name or 'Indefinido').. ' '.. tostring(identity.name2 or identity.Name2 or identity.LastName or identity.Lastname or 'Indefinido')
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getCharacterIdentity(playerId) or {}
        
        return tostring(identity.name or 'Indefinido').. ' '.. tostring(identity.name2 or 'Indefinido')
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerAge',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return tonumber(identity.age or identity.Age or identity.Idade) or 21
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerAge',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return tonumber(identity.age or identity.Age or identity.Idade) or 21
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerAge',
    function(playerId)
        local identity = frameworkFunctions.serverSide.userIdentity(playerId) or {}

        return tonumber(identity.age or identity.Age or identity.Idade) or 21
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerAge',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}
        
        return tonumber(identity.age or identity.Age or identity.Idade) or 21
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerAge',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getCharacterIdentity(playerId) or {}
        
        return tonumber(identity.age or identity.Age or identity.Idade) or 21
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return 'REGISTRO_DO_JOGADOR'
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return 'REGISTRO_DO_JOGADOR'
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.userIdentity(playerId) or {}

        return 'REGISTRO_DO_JOGADOR'
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}
        
        return 'REGISTRO_DO_JOGADOR'
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getCharacterIdentity(playerId) or {}
        
        return 'REGISTRO_DO_JOGADOR'
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return 0
    end,
    { canExecute = getFrameworkChecker('vrp'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getUserIdentity(playerId) or {}
        
        return 0
    end,
    { canExecute = getFrameworkChecker('creativeV4'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.userIdentity(playerId) or {}

        return 0
    end,
    { canExecute = getFrameworkChecker('creativeV5'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}
        
        return 0
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.getCharacterIdentity(playerId) or {}
        
        return 0
    end,
    { canExecute = getFrameworkChecker('snt-base'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canOpenPainel',
    function(playerSource)
        local isPolice = executeAdapter('isPlayerPolice', playerSource)

        return isPolice
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'isPlayerPolice',
    function(playerSource)
        return true
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerPoliceRanking',
    function(playerSource)
        return 'Soldado'
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'isPlayerInService',
    function(playerSource)
        return true
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerIdByIdentifier',
    function(searchIdentifier)
        return executeAdapter('getPlayerId', tonumber(searchIdentifier) or searchIdentifier)
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getServerPolices',
    function()
        return {}
    end,
    { priority = FRAMEWORK_PRIORITY }
)