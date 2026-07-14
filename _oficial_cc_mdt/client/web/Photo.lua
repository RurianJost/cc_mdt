RegisterNUICallback('setAvatarURL', function(data, callback)
    apiServer.updateAvatarURL(data.avatarURL)

    callback({})
end)

RegisterNUICallback('initAvatarPicture', function(data, callback)
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)

    Citizen.CreateThread(function()
        local photoURL = executeAdapter('takePhoto', true, true)
                
        setAvatarPicture(photoURL)
    end)

    callback({})
end)

function setAvatarPicture(avatarURL)
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
        action = 'setAvatarPictureForm',
        data = avatarURL
    })
end

RegisterNUICallback('initPhotoPicture', function(data, callback)
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)

    Citizen.CreateThread(function()
        local photoURL = executeAdapter('takePhoto')

        setPictureForm(photoURL)
    end)

    callback({})
end)

function setPictureForm(photoURL)
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
        action = 'setPictureForm',
        data = photoURL
    })
end

RegisterNUICallback('initVehiclePicture', function(data, callback)
    SetNuiFocus(false, false)
    SetCursorLocation(0.5, 0.5)

    Citizen.CreateThread(function()
        local photoURL = executeAdapter('takePhoto')

        setVehiclePictureForm(photoURL)
    end)

    callback({})
end)

function setVehiclePictureForm(photoURL)
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
        action = 'setVehiclePictureForm',
        data = photoURL
    })
end