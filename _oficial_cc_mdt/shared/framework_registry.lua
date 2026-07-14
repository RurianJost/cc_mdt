local frameworksRegistered = {}
local currentFrameworkName = nil
local frameworkFunctions = nil

local printedDetected = false
local printedNone = false

_G.isAdapterReady = false

local function debugPrint(msg)
    if _G.__adapterFrameworkDebug then
        print('[framework] ' .. msg)
    end
end

function setFrameworkDebug(enabled)
    _G.__adapterFrameworkDebug = not not enabled
end

function registerFramework(frameworkName, verifyFramework, getHandleToFramework)
    assert(type(frameworkName) == 'string', 'registerFramework: frameworkName must be string')
    assert(type(verifyFramework) == 'function', 'registerFramework: verifyFramework must be function')
    assert(type(getHandleToFramework) == 'function', 'registerFramework: getHandleToFramework must be function')

    local getFunctionsFactory = getHandleToFramework()

    frameworksRegistered[frameworkName] = {
        verifyFramework = verifyFramework,
        getFunctions = getFunctionsFactory
    }

    debugPrint(("registered '%s'"):format(frameworkName))
end

local isServer = IsDuplicityVersion()

local function setDetectedFramework(name, funcs)
    frameworkFunctions = funcs
    currentFrameworkName = name

    _G.frameworkFunctions = frameworkFunctions
    _G.currentFrameworkName = currentFrameworkName
    _G.isAdapterReady = true

    if not printedDetected then
        if isServer then
            print(('^1['..GetCurrentResourceName()..'] ^2[ADAPTER] ^0Framework detectada: ^9%s^0'):format(tostring(name)))
        end

        printedDetected = true
    end
end

local function printNoneDetectedOnce()
    if not printedNone and not currentFrameworkName then
        if isServer then
            print('^1['..GetCurrentResourceName()..'] ^2[ADAPTER] ^8Nenhuma framework detectada.^0')
        end

        printedNone = true
    end
end

local function tryDetectFramework(frameworkName)
    if currentFrameworkName then
        return currentFrameworkName == frameworkName
    end

    local fw = frameworksRegistered[frameworkName]

    if not fw then 
        return false 
    end

    local okGet, funcs = pcall(fw.getFunctions)

    if not okGet then
        debugPrint(("getFunctions error '%s': %s"):format(frameworkName, tostring(funcs)))
        
        return false
    end

    local okVerify, isOk = pcall(fw.verifyFramework, funcs)
   
    if not okVerify then
        debugPrint(("verifyFramework error '%s': %s"):format(frameworkName, tostring(isOk)))
        
        return false
    end

    if not isOk then
        return false
    end

    setDetectedFramework(frameworkName, funcs)

    return true
end

function getFrameworkChecker(frameworkName)
    return function()
        return tryDetectFramework(frameworkName)
    end
end

function getScriptStartedChecker(scriptName)
    return function()
        return GetResourceState(scriptName) == "started"
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(0)

    for name in pairs(frameworksRegistered) do
        if tryDetectFramework(name) then
            return
        end
    end

    printNoneDetectedOnce()
end)

function invalidateFrameworkDetection()
    currentFrameworkName = nil
    frameworkFunctions = nil
    _G.currentFrameworkName = nil
    _G.frameworkFunctions = nil
    _G.isAdapterReady = false

    printedDetected = false
    printedNone = false
end