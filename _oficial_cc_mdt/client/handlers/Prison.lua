_G.Prison = {
    cache = {}
}

local function getTaskByIndex(taskIndex)
    if not PRISON_CONFIG.TASKS then
        return nil
    end

    return PRISON_CONFIG.TASKS[taskIndex]
end

local function getTaskMarker(task)
    if task and task.MARKER then
        return task.MARKER
    end

    return {
        TYPE = 1,
        SCALE = vector3(1.0, 1.0, 1.0),
        RGBA = { 255, 255, 255, 180 },
        textureDict = nil,
        textureName = nil
    }
end

local function getTaskDistance(task, playerCoordinates)
    if not task or not task.LOCATION or not task.LOCATION.COORDINATES then
        return nil
    end

    return #(playerCoordinates - task.LOCATION.COORDINATES)
end

local function drawTaskMarker(task)
    if not task or not task.LOCATION or not task.LOCATION.COORDINATES then
        return
    end

    local marker = getTaskMarker(task)
    local scale = marker.SCALE or vector3(1.0, 1.0, 1.0)
    local rgba = marker.RGBA or { 255, 255, 255, 180 }
    local coords = task.LOCATION.COORDINATES
    local textureDict = marker.textureDict
    local textureName = marker.textureName
    local hasTexture = textureDict and textureName and HasStreamedTextureDictLoaded(textureDict)

    if textureDict and not hasTexture then
        RequestStreamedTextureDict(textureDict, false)
    end

    if hasTexture then
        DrawMarker(
            marker.TYPE or 9,
            coords.x, coords.y, coords.z - 0.95,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            scale.x or 1.0, scale.y or 1.0, scale.z or 1.0,
            rgba[1] or 255, rgba[2] or 255, rgba[3] or 255, rgba[4] or 180,
            false, false, 2, false,
            textureDict, textureName, false
        )
    else
        DrawMarker(
            marker.TYPE or 9,
            coords.x, coords.y, coords.z - 0.95,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            scale.x or 1.0, scale.y or 1.0, scale.z or 1.0,
            rgba[1] or 255, rgba[2] or 255, rgba[3] or 255, rgba[4] or 180,
            false, false, 2, false,
            nil, nil, false
        )
    end
end

function Prison:UpdateSentence(sentence, releaseTick)
    self.cache.sentence = tonumber(sentence) or self.cache.sentence or 1
    self.cache.releaseTick = tonumber(releaseTick) or self.cache.releaseTick or 0
    self.cache.lastShownSentence = nil

    showSentence(self.cache.sentence)
end

function Prison:GetTaskSequenceIndex()
    local taskCount = #(PRISON_CONFIG.TASKS or {})

    if taskCount <= 0 then
        return 1
    end

    local currentIndex = tonumber(self.cache.taskState and self.cache.taskState.nextTaskIndex) or 1

    if currentIndex < 1 or currentIndex > taskCount then
        currentIndex = 1
    end

    return currentIndex
end

function Prison:AdvanceTaskSequence()
    local taskCount = #(PRISON_CONFIG.TASKS or {})

    if taskCount <= 0 then
        self.cache.taskState.nextTaskIndex = 1
        self.cache.taskState.completed = {}

        return 1
    end

    local nextIndex = (tonumber(self.cache.taskState and self.cache.taskState.nextTaskIndex) or 1) + 1

    if nextIndex > taskCount then
        nextIndex = 1
        
        self.cache.taskState.completed = {}
    end

    self.cache.taskState.nextTaskIndex = nextIndex

    return nextIndex
end

function Prison:BuildTaskState()
    self.cache.taskState = self.cache.taskState or {}
    self.cache.taskState.completed = self.cache.taskState.completed or {}
    self.cache.taskState.nextTaskIndex = self.cache.taskState.nextTaskIndex or 1
end

function Prison:StartTask(taskIndex)
    if self.cache.task then
        return false
    end

    local task = getTaskByIndex(taskIndex)

    if not task then
        return false
    end

    local canStart, errorMessage = apiServer.startPrisonTask(taskIndex)

    if not canStart then
        executeAdapter('notifyPlayer', errorMessage or LANGUAGE.PRISON_TASK_START_FAILED)

        return false
    end

    self:BuildTaskState()

    local playerPed = PlayerPedId()
    local duration = tonumber(task.DURATION_SECONDS) or 0
    local coords = task.LOCATION and task.LOCATION.COORDINATES

    self.cache.task = {
        index = taskIndex,
        data = task,
        startedAt = GetGameTimer(),
        finishAt = GetGameTimer() + (duration * 1000),
        reduce = tonumber(task.REDUCE) or 0,
        object = nil,
        blip = nil,
        allowWalk = task.ANIMATIONS and task.ANIMATIONS.ALLOW_WALK or false
    }

    if coords then
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z - 0.98)
        SetEntityHeading(playerPed, task.LOCATION.HEADING or GetEntityHeading(playerPed))
    end

    if task.ANIMATIONS then
        executeAdapter('createPrisonTaskAnimation', playerPed, task.ANIMATIONS)

        if self.cache.task.allowWalk then
            executeAdapter('setPrisonTaskMovement', playerPed, true)
        end
    end

    if task.OBJECT then
        self.cache.task.object = executeAdapter('createPrisonTaskObject', playerPed, task.OBJECT)
    end

    if task.LOCATION and task.LOCATION.COORDINATES then
        self.cache.task.blip = executeAdapter('createPrisonTaskBlipLocation', {
            x = task.LOCATION.COORDINATES.x,
            y = task.LOCATION.COORDINATES.y,
            z = task.LOCATION.COORDINATES.z
        }, task.BLIP)
    end

    executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_STARTED:format(task.NAME or LANGUAGE.PRISON_TASK_DEFAULT_NAME))

    return true
end

function Prison:CompleteTask()
    if not self.cache.task then
        return false
    end

    local task = self.cache.task.data
    local reduceMinutes = self.cache.task.reduce or 0

    if reduceMinutes <= 0 then
        self:StopTask()

        return false
    end

    local success, sentence, releaseTick = apiServer.reducePrisonSentence(self.cache.task.index)

    if not success then
        executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_REDUCE_FAILED)

        self:StopTask()

        return false
    end

    if sentence and sentence > 0 then
        executeAdapter('updatePrisonSentence', sentence, releaseTick)
    else
        executeAdapter('updatePrisonSentence', 0, releaseTick)
    end

    if self.cache.taskState and self.cache.taskState.completed then
        self.cache.taskState.completed[self.cache.task.index] = true
        self.cache.taskState.nextTaskIndex = self:AdvanceTaskSequence()
    end

    executeAdapter('notifyPlayer', LANGUAGE.PRISON_TASK_COMPLETED:format(task.NAME or LANGUAGE.PRISON_TASK_DEFAULT_NAME, reduceMinutes))

    self:StopTask()

    return true
end

function Prison:StopTask()
    if not self.cache.task then
        return
    end

    local playerPed = PlayerPedId()

    executeAdapter('stopAnimation', playerPed)
    executeAdapter('setPrisonTaskMovement', playerPed, false)

    if self.cache.task.object then
        executeAdapter('deleteObject', self.cache.task.object)
    end

    if self.cache.task.blip then
        RemoveBlip(self.cache.task.blip)
    end

    self.cache.task = nil
end

function Prison:Insert(sentence, releaseTick)
    if self.cache.isActive then
        self.cache.sentence = tonumber(sentence) or self.cache.sentence or 1
        self.cache.releaseTick = tonumber(releaseTick) or self.cache.releaseTick or 0
        self.cache.lastShownSentence = nil

        showSentence(self.cache.sentence)

        return
    end

    self.cache.isActive = true
    self.cache.polyzone = PolyZone:Create(PRISON_CONFIG.COORDINATES.POLYZONE, { name = 'cc_prison' })

    self.cache.releaseTick = tonumber(releaseTick) or 0
    self.cache.sentence = tonumber(sentence) or 1
    self.cache.lastShownSentence = nil
    self.cache.taskState = {
        completed = {},
        nextTaskIndex = 1
    }
    self.cache.task = nil

    local playerPed = PlayerPedId()

    showSentence(self.cache.sentence)

    self.cache.lastShownSentence = self.cache.sentence

    executeAdapter('onPlayerEnteredPrison', playerPed)

    Citizen.CreateThread(function()
        self:CreateMainThread()
    end)
end

function Prison:CreateMainThread()
    while self.cache.isActive do
        local playerPed = PlayerPedId()
        local playerCoordinates = GetEntityCoords(playerPed)

        if not self.cache.polyzone:isPointInside(playerCoordinates) then
            if not self.cache.isOutside then
                self.cache.isOutside = true

                executeAdapter('notifyPlayer', LANGUAGE.PRISON_ESCAPE_ATTEMPT)
            end

            executeAdapter('onPlayerLeftPrisonArea', playerPed)
        else
            self.cache.isOutside = false
        end

        local isAlive = executeAdapter('isPlayerAlive', playerPed)

        if not isAlive then
            if not self.cache.isDead then
                self.cache.isDead = true

                executeAdapter('notifyPlayer', LANGUAGE.PRISON_DEATH)
            end

            executeAdapter('onPlayerDeathInPrison', playerPed)
        else
            self.cache.isDead = false
        end

        if self.cache.releaseTick and self.cache.releaseTick > 0 then
            local remainingSeconds = math.max(0, math.floor(self.cache.releaseTick))
            local remainingSentence = math.max(1, math.ceil(remainingSeconds / 60))

            if remainingSentence ~= self.cache.lastShownSentence then
                self.cache.lastShownSentence = remainingSentence

                showSentence(remainingSentence)
            end
        end

        for taskIndex, task in ipairs(PRISON_CONFIG.TASKS or {}) do
            if task.LOCATION and task.LOCATION.COORDINATES then
                drawTaskMarker(task)

                if not self.cache.task then
                    local nextTaskIndex = self:GetTaskSequenceIndex()

                    if taskIndex == nextTaskIndex then
                        local distance = getTaskDistance(task, playerCoordinates)
                        local zDifference = math.abs(playerCoordinates.z - task.LOCATION.COORDINATES.z)

                        if distance and distance <= 2.0 and zDifference <= 2.0 and IsControlJustReleased(0, 38) then
                            self:StartTask(taskIndex)
                        end
                    end
                end
            end
        end

        if self.cache.task and self.cache.task.finishAt and GetGameTimer() >= self.cache.task.finishAt then
            self:CompleteTask()
        end

        Citizen.Wait(0)
    end
end

function Prison:Remove(isScaped)
    if self.cache.isActive then
        self.cache.isActive = false
    
        local playerPed = PlayerPedId()

        hideSentence()

        self:StopTask()

        if isScaped then
            executeAdapter('notifyPlayer', LANGUAGE.PRISON_ESCAPE_ATTEMPT)
            executeAdapter('onPlayerEscapedFromPrison', playerPed)
        else
            executeAdapter('notifyPlayer', LANGUAGE.PRISON_RELEASED)
            executeAdapter('onPlayerReleasedFromPrison', playerPed)
        end

        self.cache = {}
        self.cache.task = nil
    end
end

function Prison:IsActive()
    return not not self.cache.isActive
end
