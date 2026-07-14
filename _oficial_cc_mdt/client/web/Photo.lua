RegisterNUICallback('initPhotoPicture', function(data, callback)
    SetTimeout(3000, function()
        setPictureForm('https://cdn.discordapp.com/attachments/920863698535448603/1491517085942157474/PitBull_Sorrindo_500x500.png?ex=69d7fb08&is=69d6a988&hm=f3d37f79c05665a0b8c997fec2412917d7d017fd13667929a491ac032cb09d05&')
    end)
    
    callback({})
end)

function setPictureForm(photoURL)
    SendNUIMessage({
        action = 'setPictureForm',
        data = photoURL
    })
end