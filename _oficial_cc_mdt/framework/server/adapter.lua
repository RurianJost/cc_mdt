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
        local queries = {
            [[
                CREATE TABLE IF NOT EXISTS `cc_mdt_ocurrences` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `officer_id` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
                    `suspect_id` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
                    `suspect_description` TEXT NOT NULL COLLATE 'latin1_swedish_ci',
                    `crimes` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                    `attenuants` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                    `aggravants` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
                    `photo_url` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
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
            ]],
            [[
                CREATE TABLE IF NOT EXISTS `cc_mdt_profile_photos` (
                    `player_id` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `photo_url` LONGTEXT NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
                    PRIMARY KEY (`player_id`) USING BTREE
                )
                COLLATE='latin1_swedish_ci'
                ENGINE=InnoDB
            ]],
            [[
                CREATE TABLE IF NOT EXISTS `cc_mdt_player_sentences` (
                    `player_id` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `occurrence_id` INT(11) NOT NULL,
                    `sentence` INT(11) NOT NULL DEFAULT '0',
                    PRIMARY KEY (`player_id`, `occurrence_id`) USING BTREE
                )
                COLLATE='latin1_swedish_ci'
                ENGINE=InnoDB
            ]],
            [[
                CREATE TABLE IF NOT EXISTS `cc_mdt_player_prisons` (
                    `player_id` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `occurrence_id` INT(11) NOT NULL,
                    `officer_id` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `sentence` INT(11) NOT NULL DEFAULT '0',
                    `release_at` INT(11) NOT NULL DEFAULT '0',
                    `original_clothes` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
                    `created_at` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
                    PRIMARY KEY (`player_id`) USING BTREE
                )
                COLLATE='latin1_swedish_ci'
                ENGINE=InnoDB
            ]],
            [[
                CREATE TABLE IF NOT EXISTS `cc_mdt_fine_record` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `type` ENUM('USER','VEHICLE') NOT NULL COLLATE 'latin1_swedish_ci',
                    `target_identifier` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `fine_id` INT(11) NOT NULL,
                    `description` TEXT NOT NULL COLLATE 'latin1_swedish_ci',
                    `value` INT(11) NOT NULL DEFAULT '0',
                    `officer_id` VARCHAR(64) NOT NULL COLLATE 'latin1_swedish_ci',
                    `created_at` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
                    PRIMARY KEY (`id`) USING BTREE
                )
                COLLATE='latin1_swedish_ci'
                ENGINE=InnoDB
            ]]
        }

        for _, query in ipairs(queries) do
            executeAdapter('executeSync', query, {})
        end
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getDatabaseOcurrences',
    function()
        local formattedOcurrences = {}
        local consultResult = executeAdapter('executeSync', 'SELECT *, UNIX_TIMESTAMP(created_at) AS created_at_timestamp FROM cc_mdt_ocurrences', {})
    
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
                createdAt = tonumber(row.created_at_timestamp) or row.created_at
            }
        end

        return formattedOcurrences
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'createOcurrence',
    function(officerId, suspectId, suspectDescription, crimes, attenuants, aggravants, photoURL, penaltyPayload)
        local insertResult = executeAdapter(
            'executeSync',
            'INSERT INTO cc_mdt_ocurrences (officer_id, suspect_id, suspect_description, crimes, attenuants, aggravants, photo_url, payload, is_finished) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {
                officerId,
                suspectId,
                suspectDescription or LANGUAGE.COMMON_NOT_PROVIDED,
                json.encode(crimes),
                json.encode(attenuants or {}),
                json.encode(aggravants or {}),
                photoURL or '',
                json.encode(penaltyPayload),
                0
            }
        )

        if type(insertResult) == 'table' and insertResult.insertId then
            return insertResult.insertId
        else
            local consultResult = executeAdapter(
                'executeSync',
                'SELECT id FROM cc_mdt_ocurrences WHERE officer_id = ? AND suspect_id = ? AND suspect_description = ? ORDER BY id DESC LIMIT 1',
                { officerId, suspectId, suspectDescription }
            )

            return consultResult[1] and consultResult[1].id
        end
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'deleteOcurrence',
    function(ocurrenceId)
        executeAdapter('executeSync', 'DELETE FROM cc_mdt_ocurrences WHERE id = ?', { ocurrenceId })
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'updateOcurrence',
    function(ocurrenceId, setClauses, parameters)
        if type(setClauses) ~= 'table' or #setClauses == 0 or type(parameters) ~= 'table' then
            return false
        end

        local allowedClauses = {
            ['suspect_id = ?'] = true,
            ['crimes = ?'] = true,
            ['payload = ?'] = true
        }

        for _, clause in ipairs(setClauses) do
            if not allowedClauses[clause] then
                return false
            end
        end

        local queryParameters = {}

        for index, value in ipairs(parameters) do
            queryParameters[index] = value
        end

        queryParameters[#queryParameters + 1] = ocurrenceId

        local success = executeAdapter('executeSync',
            'UPDATE cc_mdt_ocurrences SET '..table.concat(setClauses, ', ')..' WHERE id = ?',
            queryParameters
        )

        return success
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'updateOcurrenceFinished',
    function(ocurrenceId, isFinished)
        executeAdapter(
            'executeAsync',
            'UPDATE cc_mdt_ocurrences SET is_finished = ? WHERE id = ?',
            { isFinished and 1 or 0, ocurrenceId }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getDatabaseProfilePhotos',
    function()
        local formattedProfilePhotos = {}
        local consultResult = executeAdapter('executeSync', 'SELECT * FROM cc_mdt_profile_photos', {})
    
        for _, row in ipairs(consultResult) do
            local playerId = tonumber(row.player_id) or row.player_id
            
            formattedProfilePhotos[playerId] = row.photo_url
        end

        return formattedProfilePhotos
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'updatePlayerProfilePhoto',
    function(playerId, photoURL)
        executeAdapter('executeAsync', 'INSERT INTO cc_mdt_profile_photos (player_id, photo_url) VALUES (?, ?) ON DUPLICATE KEY UPDATE photo_url = VALUES(photo_url);', { playerId, photoURL })
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getDatabasePrisonRecords',
    function()
        local formattedPrisonRecords = {}
        local consultResult = executeAdapter('executeSync', 'SELECT *, UNIX_TIMESTAMP(created_at) AS created_at_timestamp FROM cc_mdt_player_prisons', {})

        for _, row in ipairs(consultResult) do
            local playerId = tostring(row.player_id)
            local occurrenceId = tonumber(row.occurrence_id) or row.occurrence_id
            local officerId = tostring(row.officer_id)
            local sentenceValue = tonumber(row.sentence) or 0
            local releaseTick = tonumber(row.release_at) or 0
            local originalClothes = nil

            if type(row.original_clothes) == 'string' and row.original_clothes ~= '' then
                local success, decoded = pcall(json.decode, row.original_clothes)

                if success and type(decoded) == 'table' then
                    originalClothes = decoded
                end
            end

            formattedPrisonRecords[playerId] = {
                playerId = playerId,
                occurrenceId = occurrenceId,
                officerId = officerId,
                sentence = sentenceValue,
                releaseTick = releaseTick,
                originalClothes = originalClothes,
                createdAt = tonumber(row.created_at_timestamp) or row.created_at
            }
        end

        return formattedPrisonRecords
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'upsertPrisonRecord',
    function(playerId, occurrenceId, officerId, sentenceValue, releaseTick, originalClothes)
        executeAdapter(
            'executeAsync',
            'INSERT INTO cc_mdt_player_prisons (player_id, occurrence_id, officer_id, sentence, release_at, original_clothes) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE occurrence_id = VALUES(occurrence_id), officer_id = VALUES(officer_id), sentence = VALUES(sentence), release_at = VALUES(release_at), original_clothes = VALUES(original_clothes)',
            { tostring(playerId), tonumber(occurrenceId) or occurrenceId, tostring(officerId or ''), tonumber(sentenceValue) or 0, tonumber(releaseTick) or 0, originalClothes }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'updatePrisonRecordClothes',
    function(playerId, originalClothes)
        executeAdapter(
            'executeAsync',
            'UPDATE cc_mdt_player_prisons SET original_clothes = ? WHERE player_id = ?',
            { originalClothes, tostring(playerId) }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'deletePrisonRecord',
    function(playerId)
        executeAdapter(
            'executeAsync',
            'DELETE FROM cc_mdt_player_prisons WHERE player_id = ?',
            { tostring(playerId) }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getDatabaseFineRecords',
    function()
        local formattedFineRecords = {}
        local consultResult = executeAdapter('executeSync', 'SELECT *, UNIX_TIMESTAMP(created_at) AS created_at_timestamp FROM cc_mdt_fine_record', {})

        for _, row in ipairs(consultResult) do
            formattedFineRecords[row.id] = {
                id = row.id,
                type = row.type,
                targetIdentifier = tostring(row.target_identifier),
                fineId = tonumber(row.fine_id) or row.fine_id,
                description = row.description,
                value = tonumber(row.value) or 0,
                officerId = tostring(row.officer_id),
                createdAt = tonumber(row.created_at_timestamp) or row.created_at
            }
        end

        return formattedFineRecords
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'createFineRecord',
    function(recordType, targetIdentifier, fineId, description, fineValue, officerId)
        local insertResult = executeAdapter(
            'executeSync',
            'INSERT INTO cc_mdt_fine_record (type, target_identifier, fine_id, description, value, officer_id) VALUES (?, ?, ?, ?, ?, ?)',
            {
                tostring(recordType),
                tostring(targetIdentifier),
                tonumber(fineId) or fineId,
                tostring(description or ''),
                tonumber(fineValue) or 0,
                tostring(officerId or '')
            }
        )

        if type(insertResult) == 'table' and insertResult.insertId then
            return insertResult.insertId
        end

        local consultResult = executeAdapter(
            'executeSync',
            'SELECT id FROM cc_mdt_fine_record WHERE type = ? AND target_identifier = ? AND fine_id = ? AND officer_id = ? ORDER BY id DESC LIMIT 1',
            { tostring(recordType), tostring(targetIdentifier), tonumber(fineId) or fineId, tostring(officerId or '') }
        )

        return consultResult[1] and consultResult[1].id
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'createFineRecords',
    function(recordType, targetIdentifier, fineEntries, officerId)
        local valuesSql = {}
        local parameters = {}

        for _, fineEntry in ipairs(fineEntries or {}) do
            valuesSql[#valuesSql + 1] = '(?, ?, ?, ?, ?, ?)'
            parameters[#parameters + 1] = tostring(recordType)
            parameters[#parameters + 1] = tostring(targetIdentifier)
            parameters[#parameters + 1] = tonumber(fineEntry.fineId) or fineEntry.fineId or 0
            parameters[#parameters + 1] = tostring(fineEntry.description or '')
            parameters[#parameters + 1] = tonumber(fineEntry.value) or 0
            parameters[#parameters + 1] = tostring(officerId or '')
        end

        if #valuesSql == 0 then
            return
        end

        local insertResult = executeAdapter(
            'executeSync',
            'INSERT INTO cc_mdt_fine_record (type, target_identifier, fine_id, description, value, officer_id) VALUES ' .. table.concat(valuesSql, ', '),
            parameters
        )

        if type(insertResult) == 'table' and insertResult.insertId then
            return insertResult.insertId
        end
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'updateFineRecord',
    function(recordId, recordType, targetIdentifier, fineId, description, fineValue, officerId)
        executeAdapter(
            'executeAsync',
            'UPDATE cc_mdt_fine_record SET type = ?, target_identifier = ?, fine_id = ?, description = ?, value = ?, officer_id = ? WHERE id = ?',
            {
                tostring(recordType),
                tostring(targetIdentifier),
                tonumber(fineId) or fineId,
                tostring(description or ''),
                tonumber(fineValue) or 0,
                tostring(officerId or ''),
                tonumber(recordId) or recordId
            }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'deleteFineRecord',
    function(recordId)
        executeAdapter(
            'executeAsync',
            'DELETE FROM cc_mdt_fine_record WHERE id = ?',
            { tonumber(recordId) or recordId }
        )
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerFramework(
    'vrp', 
    function(framework)
        if GetResourceState('vrp') ~= 'started' or not framework then 
            return false
        end 

        local hasGroups = pcall(function()
            return require('vrp', 'cfg/groups')
        end)
    
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

        local hasNative = pcall(function()
            return require('vrp', 'config/Native')
        end)
    
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
                return { serverSide = ESX }
            end
        end
    end
)

registerFramework(
    'qbox',
    function(framework)
        return GetResourceState('qbx_core') == 'started' and framework
    end,
    function()
        return function()
            return { serverSide = exports.qbx_core }
        end
    end
)

registerFramework(
    'qbus',
    function(framework)
        return GetResourceState('qb-core') == 'started' and GetResourceState('qbx_core') == 'stopped' and framework
    end,
    function()
        return function()
            local hasCore = GetResourceState('qb-core') == 'started'
            local frameworkFunctions = {}

            if hasCore then
                frameworkFunctions.serverSide = exports['qb-core']:GetCoreObject()

                RegisterNetEvent('QBCore:Server:UpdateObject', function()
                    frameworkFunctions.serverSide = exports['qb-core']:GetCoreObject()
                end)
            end

            return frameworkFunctions
        end
    end
)

registerFramework(
    'tnet',
    function(framework)
        return GetResourceState('tnet_core') == 'started' and framework
    end,
    function()
        return function()
            local hasCore = GetResourceState('tnet_core') == 'started'
            local frameworkFunctions = {}

            if hasCore then
                frameworkFunctions.serverSide = exports.tnet_core:getSharedObject()

                AddEventHandler('onResourceStart', function(resourceName)
                    if resourceName ~= 'tnet_core' then
                        return
                    end

                    while GetResourceState('tnet_core') ~= 'started' do
                        Wait(100)
                    end

                    frameworkFunctions.serverSide = exports.tnet_core:getSharedObject()
                end)
            end

            return frameworkFunctions
        end
    end
)

registerAdapter(
    'getPlayerId',
    function(source)
        return frameworkFunctions.serverSide.Passport(source)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getSourceFromPlayerId',
    function(playerId)
        return frameworkFunctions.serverSide.Source(playerId)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
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
        end

        return frameworkFunctions.serverSide.HasPermission(playerId, permission) 
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerName',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}
        
        return tostring(identity.name or identity.Name or LANGUAGE.COMMON_UNDEFINED).. ' '.. tostring(identity.name2 or identity.Name2 or identity.LastName or identity.Lastname or LANGUAGE.COMMON_UNDEFINED)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
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
    'getPlayerRegistration',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}

        return tostring(identity.registration or identity.Registration or identity.Registro or identity.Identidade or playerId)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerFineValue',
    function(playerId)
        local identity = frameworkFunctions.serverSide.Identity(playerId) or {}

        return tonumber(identity.fines) or 0
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'givePlayerFine',
    function(playerId, fineAmount, issuerId, description)
        frameworkFunctions.serverSide.GiveFine(playerId, fineAmount)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'notifyPlayer',
    function(source, message)
        TriggerClientEvent('Notify', source, 'warn', message, 10000)
    end,
    { priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'isPlayerPolice',
    function(playerSource)
        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            if executeAdapter('hasPlayerPermission', playerSource, CONFIG.PERMISSIONS.ROLE) then
                return true, ORGANIZATION_NAME
            end
        end

        return false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

local function getPoliceMembershipById(playerId, policeOrganization)
    local strPlayerId = tostring(playerId)

    for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
        if not policeOrganization or ORGANIZATION_NAME == policeOrganization then
            local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..CONFIG.PERMISSIONS.ROLE) or {}
            local hierarchy = permissionData[strPlayerId]

            if hierarchy then
                return true, ORGANIZATION_NAME, tonumber(hierarchy) or hierarchy
            end
        end
    end

    return false
end

registerAdapter(
    'isPlayerPoliceById',
    function(playerId, policeOrganization)
        return getPoliceMembershipById(playerId, policeOrganization)
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

serverPermissions = nil

registerAdapter(
    'getPlayerPoliceRanking',
    function(playerId)
        if not serverPermissions then
            require('vrp', 'config/Groups')
            
            serverPermissions = Groups
        end

        local strPlayerId = tostring(playerId)

        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..CONFIG.PERMISSIONS.ROLE)

            if permissionData[strPlayerId] then
                local serverPermissionData = serverPermissions[CONFIG.PERMISSIONS.ROLE]

                if serverPermissionData and serverPermissionData.Hierarchy then
                    return serverPermissionData.Hierarchy[permissionData[strPlayerId]]
                end
            end
        end

        return LANGUAGE.OFFICER_RANK_UNDEFINED
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'isPlayerInService',
    function(playerSource)
        local playerId = executeAdapter('getPlayerId', playerSource)

        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            local isService = frameworkFunctions.serverSide.HasService(playerId, CONFIG.PERMISSIONS.ROLE)

            if isService then
                return true
            end
        end

        return false 
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPlayerIdByIdentifier',
    function(searchIdentifier)
        return searchIdentifier
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getPolices',
    function(policeOrganization)
        local serverPolices = {}

        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            local canPass = true

            if policeOrganization and ORGANIZATION_NAME ~= policeOrganization then
                canPass = false
            end

            if canPass then
                local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..CONFIG.PERMISSIONS.ROLE)

                for playerId, hierarchie in pairs(permissionData) do
                    table.insert(serverPolices, tonumber(playerId) or playerId)
                end
            end
        end

        return serverPolices
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getOnlinePolices',
    function(policeOrganization)
        local onlinePolices = {}

        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            local canPass = true

            if policeOrganization and ORGANIZATION_NAME ~= policeOrganization then
                canPass = false
            end

            if canPass then
                local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..CONFIG.PERMISSIONS.ROLE)

                for playerId, hierarchie in pairs(permissionData) do
                    local playerSource = executeAdapter('getSourceFromPlayerId', playerId)

                    if playerSource then
                        table.insert(onlinePolices, {
                            source = playerSource,
                            id = tonumber(playerId) or playerId, 
                            organization = ORGANIZATION_NAME
                        })
                    end
                end
            end
        end

        return onlinePolices
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getOnlinePolicesInService',
    function(policeOrganization)
        local policesInService = {}

        for ORGANIZATION_NAME, CONFIG in pairs(ORGANIZATIONS_CONFIG) do
            local canPass = true

            if policeOrganization and ORGANIZATION_NAME ~= policeOrganization then
                canPass = false
            end

            if canPass then
                local playersInService = frameworkFunctions.serverSide.NumPermission(CONFIG.PERMISSIONS.ROLE)
    
                for playerId, playerSource in pairs(playersInService) do
                    table.insert(policesInService, {
                        source = playerSource,
                        id = tonumber(playerId) or playerId, 
                        organization = ORGANIZATION_NAME
                    })
                end
            end
        end

        return policesInService
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getVehicleOwnerFromPlate',
    function(vehiclePlate)
        local vehicleData = exports['nation-garages']:getVehicleData(vehiclePlate)

        return tonumber(vehicleData.user) or vehicleData.user
    end,
    { canExecute = getScriptStartedChecker('nation-garages'), priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'getVehicleOwnerFromPlate',
    function(vehiclePlate)
        local plateObject = frameworkFunctions.serverSide.PassportPlate(vehiclePlate)

        if type(plateObject) == 'number' then
            return plateObject
        elseif type(plateObject) == 'table' then
            return plateObject.Passport
        end
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'getVehicleModelFromPlate',
    function(vehiclePlate)
        local vehicleData = exports['nation-garages']:getVehicleData(vehiclePlate, nil)

        if vehicleData then
            return vehicleData.vehicle or vehicleData.model or vehicleData.name
        end
    end,
    { canExecute = getScriptStartedChecker('nation-garages'), priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'getVehicleModelFromPlate',
    function(vehiclePlate)
        local plateObject = frameworkFunctions.serverSide.PassportPlate(vehiclePlate:gsub(' ', ''))

        if type(plateObject) == 'table' then
            return plateObject.vehicle or plateObject.Vehicle
        end
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'isVehicleDetained',
    function(vehiclePlate, modelName, playerOwnerId)
        local vehicleData = exports['nation-garages']:getVehicleData(vehiclePlate, nil)

        if not vehicleData or not next(vehicleData) then
            return false
        end

        local arrested = vehicleData.status

        return arrested == 'detido' or arrested == 'roubado' or arrested == 'expirado'
    end,
    { canExecute = getScriptStartedChecker('nation-garages'), priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'isVehicleDetained',
    function(vehiclePlate)
        local plateObject = frameworkFunctions.serverSide.PassportPlate(vehiclePlate:gsub(' ', ''))

        if type(plateObject) ~= 'table' then
            return false
        end

        local arrested = plateObject.Arrest or plateObject.arrest

        return type(arrested) == 'number' and arrested > os.time() or arrested == 1 or false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

serverVehicles = nil

registerAdapter(
    'getVehicleNameByModel',
    function(modelHash)
        serverVehicles = serverVehicles or exports['nation-garages']:getVehList()

        for index, vehicleInfo in pairs(serverVehicles) do
            if GetHashKey(vehicleInfo.model) == modelHash then
                return vehicleInfo.model
            end
        end
    end,
    { canExecute = getScriptStartedChecker('nation-garages'), priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'getVehicleNameByModel',
    function(modelHash)
        local garage = Proxy.getInterface('nation_garages')

        serverVehicles = serverVehicles or garage.getVehList()

        for index, vehicleInfo in pairs(serverVehicles) do
            if GetHashKey(vehicleInfo.name) == modelHash then
                return vehicleInfo.name
            end
        end
    end,
    { canExecute = getScriptStartedChecker('nation_garages'), priority = SCRIPT_PRIORITY }
)

registerAdapter(
    'getVehicleNameByModel',
    function(modelHash)
        if not serverVehicles then 
            require('vrp', 'config/Vehicle')

            if VehicleGlobal then
                serverVehicles = VehicleGlobal()
            elseif VehicleList then
                serverVehicles = VehicleList()
            else
                error(LANGUAGE.ADAPTER_GLOBAL_VEHICLES_FUNCTION_NOT_FOUND)
            end
        end 

        for modelName in pairs(serverVehicles) do
            if GetHashKey(modelName) == modelHash then
                return modelName
            end
        end
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
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
    'canFirePolice',
    function(playerSource, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            return executeAdapter('hasPlayerPermission', playerSource, ORG_CONFIG.PERMISSIONS.TO_FIRE)
        end

        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canPromotePolice',
    function(playerSource, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            return executeAdapter('hasPlayerPermission', playerSource, ORG_CONFIG.PERMISSIONS.TO_PROMOTE)
        end

        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canDemotePolice',
    function(playerSource, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            return executeAdapter('hasPlayerPermission', playerSource, ORG_CONFIG.PERMISSIONS.TO_DEMOTE)
        end

        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canHirePolice',
    function(playerSource, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            return executeAdapter('hasPlayerPermission', playerSource, ORG_CONFIG.PERMISSIONS.TO_HIRE)
        end

        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canDeleteRegister',
    function(playerSource, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            return executeAdapter('hasPlayerPermission', playerSource, ORG_CONFIG.PERMISSIONS.TO_DELETE_REGISTER)
        end

        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'canManageOfficers',
    function(playerSource, policeOrganization)
        return false
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'isValidVehiclePlate',
    function(search)
        if search == nil then
            return false
        end

        local normalized = tostring(search):upper():gsub('%s+', ''):gsub('%-', '')

        if #normalized ~= 8 then
            return false
        end

        return normalized:match('^%d%d%u%u%u%d%d%d$') ~= nil
    end,
    { priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'firePolice',
    function(officerId, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            frameworkFunctions.serverSide.RemovePermission(officerId, ORG_CONFIG.PERMISSIONS.ROLE)

            return true
        end

        return false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'hirePolice',
    function(officerId, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            frameworkFunctions.serverSide.SetPermission(officerId, ORG_CONFIG.PERMISSIONS.ROLE)

            return true
        end

        return false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'promotePolice',
    function(officerId, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..ORG_CONFIG.PERMISSIONS.ROLE)
            local currentHierarchy = tonumber(permissionData and permissionData[tostring(officerId)])

            if not currentHierarchy or currentHierarchy <= 1 then
                return false
            end

            frameworkFunctions.serverSide.SetPermission(officerId, ORG_CONFIG.PERMISSIONS.ROLE, currentHierarchy - 1)

            return true
        end

        return false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)

registerAdapter(
    'demotePolice',
    function(officerId, policeOrganization)
        local ORG_CONFIG = ORGANIZATIONS_CONFIG[policeOrganization]

        if ORG_CONFIG then
            local permissionData = frameworkFunctions.serverSide.GetSrvData('Permissions:'..ORG_CONFIG.PERMISSIONS.ROLE)
            local currentHierarchy = tonumber(permissionData and permissionData[tostring(officerId)])

            if not currentHierarchy then
                return false
            end

            frameworkFunctions.serverSide.SetPermission(officerId, ORG_CONFIG.PERMISSIONS.ROLE, currentHierarchy + 1)

            return true
        end

        return false
    end,
    { canExecute = getFrameworkChecker('creativeNW'), priority = FRAMEWORK_PRIORITY }
)
