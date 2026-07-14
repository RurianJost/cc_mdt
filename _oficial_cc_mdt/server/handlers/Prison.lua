_G.Prison = {
    cache = {}
}

local PRISON_MONTH_DURATION_SECONDS = 60
local PRISON_TICK_SECONDS = 1
local PRISON_TASK_MAX_DISTANCE = 5.0
local PRISON_TASK_FINISH_TOLERANCE_SECONDS = 2
local PRISON_TASK_COOLDOWN_SECONDS = 5

local function getPrisonOutfit(playerSource)
    local playerPed = GetPlayerPed(playerSource)
    local playerModel = playerPed > 0 and GetEntityModel(playerPed) or nil

    if playerModel and PRISON_CONFIG.CLOTHES_TO_SET[playerModel] then
        return PRISON_CONFIG.CLOTHES_TO_SET[playerModel]
    end

    return PRISON_CONFIG.CLOTHES_TO_SET[GetHashKey('mp_m_freemode_01')]
end

local function normalizeRemainingSeconds(releaseTick)
    local remainingSeconds = math.max(0, math.floor(tonumber(releaseTick) or 0))

    if remainingSeconds > 1000000000 then
        remainingSeconds = math.max(0, remainingSeconds - os.time())
    end

    return remainingSeconds
end

local function getRemainingSentence(prisonRecord)
    local remainingSeconds = math.max(0, math.floor(tonumber(prisonRecord and prisonRecord.remainingSeconds) or 0))

    if remainingSeconds <= 0 then
        return 0
    end

    return math.max(1, math.ceil(remainingSeconds / PRISON_MONTH_DURATION_SECONDS))
end

local function getTaskByIndex(taskIndex)
    local normalizedTaskIndex = tonumber(taskIndex)

    if not normalizedTaskIndex or not PRISON_CONFIG.TASKS then
        return nil
    end

    return PRISON_CONFIG.TASKS[normalizedTaskIndex], normalizedTaskIndex
end

local function getPlayerDistanceToTask(playerSource, task)
    if not playerSource or not task or not task.LOCATION or not task.LOCATION.COORDINATES then
        return nil
    end

    local playerPed = GetPlayerPed(playerSource)

    if not playerPed or playerPed <= 0 or not DoesEntityExist(playerPed) then
        return nil
    end

    local playerCoords = GetEntityCoords(playerPed)
    local taskCoords = task.LOCATION.COORDINATES
    local playerX = tonumber(playerCoords.x)
    local playerY = tonumber(playerCoords.y)
    local playerZ = tonumber(playerCoords.z)
    local taskX = tonumber(taskCoords.x)
    local taskY = tonumber(taskCoords.y)
    local taskZ = tonumber(taskCoords.z)

    if not playerX or not playerY or not playerZ or not taskX or not taskY or not taskZ then
        return nil
    end

    local dx = playerX - taskX
    local dy = playerY - taskY
    local dz = playerZ - taskZ

    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

local function isPlayerNearTask(playerSource, task)
    local distance = getPlayerDistanceToTask(playerSource, task)

    return distance and distance <= PRISON_TASK_MAX_DISTANCE
end

local function getMaxTaskReduce()
    local maxReduce = 0

    for _, task in ipairs(PRISON_CONFIG.TASKS or {}) do
        maxReduce = math.max(maxReduce, math.floor(tonumber(task.REDUCE) or 0))
    end

    return maxReduce
end

local function persistPrisonRecord(playerId, prisonRecord)
    executeAdapter(
        'executeAsync',
        'UPDATE cc_mdt_player_prisons SET sentence = ?, release_at = ? WHERE player_id = ?',
        {
            tonumber(prisonRecord.sentence) or 0,
            tonumber(prisonRecord.remainingSeconds) or 0,
            tostring(playerId)
        }
    )
end

function Prison:NormalizeRecord(prisonRecord)
    if not prisonRecord then
        return nil
    end

    prisonRecord.remainingSeconds = normalizeRemainingSeconds(prisonRecord.remainingSeconds or prisonRecord.releaseTick)
    prisonRecord.sentence = math.max(0, math.floor(tonumber(prisonRecord.sentence) or getRemainingSentence(prisonRecord)))
    prisonRecord.releaseTick = prisonRecord.remainingSeconds
    prisonRecord.taskSequenceIndex = tonumber(prisonRecord.taskSequenceIndex) or 1

    return prisonRecord
end

function Prison:OnResourceStart()
    self.cache = executeAdapter('getDatabasePrisonRecords') or {}

    for playerId, prisonRecord in pairs(self.cache) do
        self.cache[playerId] = self:NormalizeRecord(prisonRecord)
    end

    Citizen.CreateThread(function()
        while true do
            self:ProcessOnlinePrisoners()
            Citizen.Wait(PRISON_TICK_SECONDS * 1000)
        end
    end)

    self:ResumeActivePrisoners()
end

function Prison:OnResourceStop()
    for playerId, prisonRecord in pairs(self.cache) do
        if prisonRecord then
            self:SyncPrisonRecord(playerId, prisonRecord)
        end
    end
end

function Prison:ResumeActivePrisoners()
    for playerId, prisonRecord in pairs(self.cache) do
        prisonRecord = self:NormalizeRecord(prisonRecord)

        self.cache[playerId] = prisonRecord

        if prisonRecord and prisonRecord.remainingSeconds <= 0 then
            self:Release(playerId, true)
        else
            local playerSource = executeAdapter('getSourceFromPlayerId', playerId)

            if playerSource then
                self:ApplyToPlayer(playerSource, playerId)
            end
        end
    end
end

function Prison:SyncPrisonRecord(playerId, prisonRecord)
    if not prisonRecord then
        return false
    end

    prisonRecord.sentence = math.max(0, math.floor(tonumber(prisonRecord.sentence) or 0))
    prisonRecord.remainingSeconds = math.max(0, math.floor(tonumber(prisonRecord.remainingSeconds) or 0))
    prisonRecord.releaseTick = prisonRecord.remainingSeconds

    persistPrisonRecord(playerId, prisonRecord)

    return true
end

function Prison:Get(playerId)
    if playerId then
        return self.cache[tostring(playerId)]
    end

    return self.cache
end

function Prison:IsActive(playerId)
    return not not self:Get(playerId)
end

function Prison:Create(playerId, occurrenceId, sentenceMonths, officerId, playerSource)
    local normalizedOccurrenceId = tonumber(occurrenceId) or occurrenceId
    local prisonSentence = math.max(1, math.floor(tonumber(sentenceMonths) or 0))
    local normalizedPlayerId = tostring(playerId)

    if prisonSentence <= 0 then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local remainingSeconds = prisonSentence * PRISON_MONTH_DURATION_SECONDS
    local originalClothes = nil

    if playerSource then
        local clothes = apiClient.getPlayerClothes(playerSource)

        if type(clothes) == 'table' then
            originalClothes = clothes
        end
    end

    local persisted = executeAdapter(
        'upsertPrisonRecord',
        normalizedPlayerId,
        normalizedOccurrenceId,
        tostring(officerId or ''),
        prisonSentence,
        remainingSeconds,
        originalClothes and json.encode(originalClothes) or nil
    )

    if not persisted then
        return false, LANGUAGE.ERROR_PRISON_UPDATE_DB
    end

    self.cache[normalizedPlayerId] = {
        playerId = normalizedPlayerId,
        occurrenceId = normalizedOccurrenceId,
        officerId = tostring(officerId or ''),
        sentence = prisonSentence,
        remainingSeconds = remainingSeconds,
        releaseTick = remainingSeconds,
        originalClothes = originalClothes,
        taskSequenceIndex = 1,
        createdAt = os.time()
    }

    if playerSource then
        if not originalClothes then
            local storedClothes = apiClient.getPlayerClothes(playerSource)

            if type(storedClothes) == 'table' then
                originalClothes = storedClothes

                self.cache[normalizedPlayerId].originalClothes = storedClothes

                executeAdapter('updatePrisonRecordClothes', normalizedPlayerId, json.encode(storedClothes))
            end
        end

        self:ApplyToPlayer(playerSource, normalizedPlayerId)

        executeAdapter('notifyPlayer', playerSource, LANGUAGE.PRISON_PRISONED:format(prisonSentence))
    end

    return true
end

function Prison:ApplyToPlayer(playerSource, playerId)
    local prisonRecord = self.cache[tostring(playerId)]

    if not prisonRecord then
        return false
    end

    local prisonOutfit = getPrisonOutfit(playerSource)

    if prisonOutfit then
        apiClient.setPlayerClothes(playerSource, prisonOutfit)
    end

    apiClient.prisonPlayer(playerSource, getRemainingSentence(prisonRecord), prisonRecord.remainingSeconds)

    return true
end

function Prison:ReduceSentence(playerId, reduceMinutes)
    local prisonRecord = self.cache[tostring(playerId)]

    if not prisonRecord then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
    end

    local reduceValue = math.max(0, math.floor(tonumber(reduceMinutes) or 0))

    if reduceValue <= 0 or reduceValue > getMaxTaskReduce() then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    prisonRecord.remainingSeconds = math.max(0, (tonumber(prisonRecord.remainingSeconds) or 0) - (reduceValue * PRISON_MONTH_DURATION_SECONDS))
    prisonRecord.releaseTick = prisonRecord.remainingSeconds
    prisonRecord.sentence = getRemainingSentence(prisonRecord)

    if prisonRecord.remainingSeconds <= 0 then
        self:Release(playerId, true)

        return true, 0, 0
    end

    persistPrisonRecord(playerId, prisonRecord)

    return true, prisonRecord.sentence, prisonRecord.remainingSeconds
end

function Prison:StartTask(playerSource, playerId, taskIndex)
    local normalizedPlayerId = tostring(playerId)
    local prisonRecord = self.cache[normalizedPlayerId]

    if not prisonRecord then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
    end

    local task, normalizedTaskIndex = getTaskByIndex(taskIndex)

    if not task then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local taskCount = #(PRISON_CONFIG.TASKS or {})
    local expectedTaskIndex = tonumber(prisonRecord.taskSequenceIndex) or 1

    if taskCount > 0 and normalizedTaskIndex ~= expectedTaskIndex then
        return false, LANGUAGE.PRISON_TASK_NOT_AVAILABLE
    end

    local currentTime = os.time()

    if prisonRecord.task and prisonRecord.task.expiresAt and prisonRecord.task.expiresAt > currentTime then
        return false, LANGUAGE.PRISON_TASK_ALREADY_RUNNING
    end

    if prisonRecord.lastTaskFinishedAt and (currentTime - prisonRecord.lastTaskFinishedAt) < PRISON_TASK_COOLDOWN_SECONDS then
        return false, LANGUAGE.PRISON_TASK_COOLDOWN
    end

    if not isPlayerNearTask(playerSource, task) then
        return false, LANGUAGE.PRISON_TASK_NOT_NEAR
    end

    local duration = math.max(1, math.floor(tonumber(task.DURATION_SECONDS) or 0))
    local reduce = math.max(0, math.floor(tonumber(task.REDUCE) or 0))

    if reduce <= 0 then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    prisonRecord.task = {
        index = normalizedTaskIndex,
        startedAt = currentTime,
        duration = duration,
        reduce = reduce,
        expiresAt = currentTime + duration + 30
    }

    return true
end

function Prison:CompleteTask(playerSource, playerId, taskIndex)
    local normalizedPlayerId = tostring(playerId)
    local prisonRecord = self.cache[normalizedPlayerId]

    if not prisonRecord then
        return false, LANGUAGE.ERROR_OCCURRENCE_NOT_FOUND
    end

    local task, normalizedTaskIndex = getTaskByIndex(taskIndex)
    local taskState = prisonRecord.task

    if not task or not taskState or taskState.index ~= normalizedTaskIndex then
        return false, LANGUAGE.COMMON_REQUIRED_PARAMS
    end

    local currentTime = os.time()
    local elapsed = currentTime - (tonumber(taskState.startedAt) or currentTime)
    local requiredDuration = math.max(1, (tonumber(taskState.duration) or tonumber(task.DURATION_SECONDS) or 0) - PRISON_TASK_FINISH_TOLERANCE_SECONDS)

    if elapsed < requiredDuration then
        return false, LANGUAGE.PRISON_TASK_NOT_FINISHED
    end

    if taskState.expiresAt and currentTime > taskState.expiresAt then
        prisonRecord.task = nil

        return false, LANGUAGE.PRISON_TASK_EXPIRED
    end

    if not isPlayerNearTask(playerSource, task) then
        return false, LANGUAGE.PRISON_TASK_NOT_NEAR
    end

    local reduce = math.max(0, math.floor(tonumber(taskState.reduce) or tonumber(task.REDUCE) or 0))

    prisonRecord.task = nil
    prisonRecord.lastTaskFinishedAt = currentTime

    local success, sentence, releaseTick = self:ReduceSentence(normalizedPlayerId, reduce)

    if success and self.cache[normalizedPlayerId] then
        local taskCount = #(PRISON_CONFIG.TASKS or {})

        if taskCount > 0 then
            local nextTaskIndex = normalizedTaskIndex + 1

            if nextTaskIndex > taskCount then
                nextTaskIndex = 1
            end

            self.cache[normalizedPlayerId].taskSequenceIndex = nextTaskIndex
        end
    end

    return success, sentence, releaseTick
end

function Prison:Release(playerId, shouldRestoreClothes)
    local normalizedPlayerId = tostring(playerId)
    local prisonRecord = self.cache[normalizedPlayerId]

    if not prisonRecord then
        return false
    end

    local deleted = executeAdapter('deletePrisonRecord', normalizedPlayerId)

    if not deleted then
        return false, LANGUAGE.ERROR_PRISON_UPDATE_DB
    end

    local playerSource = executeAdapter('getSourceFromPlayerId', normalizedPlayerId)

    if playerSource then
        if shouldRestoreClothes and prisonRecord.originalClothes then
            apiClient.setPlayerClothes(playerSource, prisonRecord.originalClothes)
        end

        apiClient.removePrisonPlayer(playerSource, false)

        executeAdapter('notifyPlayer', playerSource, LANGUAGE.PRISON_RELEASED)
    end

    self.cache[normalizedPlayerId] = nil

    return true
end

function Prison:ProcessOnlinePrisoners()
    for playerId, prisonRecord in pairs(self.cache) do
        prisonRecord = self:NormalizeRecord(prisonRecord)

        self.cache[playerId] = prisonRecord

        if prisonRecord then
            local playerSource = executeAdapter('getSourceFromPlayerId', playerId)

            if playerSource then
                if prisonRecord.remainingSeconds <= 0 then
                    self:Release(playerId, true)
                else
                    prisonRecord.remainingSeconds = math.max(0, prisonRecord.remainingSeconds - 1)
                    prisonRecord.releaseTick = prisonRecord.remainingSeconds
                    prisonRecord.sentence = getRemainingSentence(prisonRecord)

                    if prisonRecord.remainingSeconds <= 0 then
                        self:Release(playerId, true)
                    end
                end
            end
        end
    end
end

function Prison:OnPlayerSpawn(playerSource, playerId)
    local prisonRecord = self.cache[tostring(playerId)]

    if not prisonRecord then
        return
    end

    prisonRecord = self:NormalizeRecord(prisonRecord)

    self.cache[tostring(playerId)] = prisonRecord

    if prisonRecord.remainingSeconds <= 0 then
        self:Release(playerId, true)
        
        return
    end

    self:ApplyToPlayer(playerSource, tostring(playerId))
end

function Prison:OnPlayerDropped(playerSource)
    local playerId = executeAdapter('getPlayerId', playerSource)

    if not playerId then
        return
    end

    local prisonRecord = self.cache[tostring(playerId)]

    if not prisonRecord then
        return
    end

    self:SyncPrisonRecord(playerId, prisonRecord)
end
