local requestPromise = nil 

function api.createRequest(requestTitle, requestDescription)
    if requestPromise then
        return false
    end

    requestPromise = promise.new()

    SendNUIMessage({
        action = 'showRequest', 
        data = {
            title = requestTitle, 
            description = requestDescription
        }
    })

    local requestResponse = Citizen.Await(requestPromise)
    
    SendNUIMessage({
        action = 'hideRequest', 
        data = {}
    })

    requestPromise = nil

    return requestResponse
end

local function acceptRequest()
    if requestPromise then
        requestPromise:resolve(true)
    end
end

local function rejectRequest()
    if requestPromise then
        requestPromise:resolve(false)
    end
end

RegisterNUICallback('respondPoliceHireRequest', function(data, callback)
    if data and data.accepted then
        acceptRequest()
    else
        rejectRequest()
    end

    callback({})
end)

Citizen.CreateThread(function()
    RegisterCommand('cc_mdt:acceptRequest', function()
        acceptRequest()
    end)
    
    RegisterCommand('cc_mdt:rejectRequest', function()
        rejectRequest()
    end)
    
    RegisterKeyMapping('cc_mdt:acceptRequest', LANGUAGE.REQUEST_ACCEPT_KEYMAPPING, 'KEYBOARD', 'Y')
    RegisterKeyMapping('cc_mdt:rejectRequest', LANGUAGE.REQUEST_REJECT_KEYMAPPING, 'KEYBOARD', 'U')
end)
