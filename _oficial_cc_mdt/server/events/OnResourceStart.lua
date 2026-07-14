Citizen.CreateThread(function()
    while not __isAuth__ do
        Citizen.Wait(1000)
    end
    
    executeAdapter('createDatabaseTables')

    Citizen.Wait(1000)

    Ocurrences:OnResourceStart()
    FineRecord:OnResourceStart()
    Prison:OnResourceStart()
    Interface:OnResourceStart()
    ProfilePhotos:Setup()
end)
