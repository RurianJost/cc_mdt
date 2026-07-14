##ABRIR A NUI

SendNUIMessage({
    action = "setVisible",
    data: true
})

##HOME

➤ Frontend
📌 getAllReports
Frontend
fetchNui<IReport[]>("getAllReports")

Backend
RegisterNUICallback("getAllReports", function(data, cb)
    local reports = {
        {
            id = "1",
            createdBy = "Rodrigo Carioca",
            description = "Alguem me assaltou!",
            handledBy = "Admin",
            coords = { x = 0, y = 0, z = 0 }
        }
    }

    cb(reports)
end)

📌 getAllCommunications
Frontend
fetchNui<Communication[]>("getAllCommunications")
Backend
RegisterNUICallback("getAllCommunications", function(data, cb)
    local communications = {
        {
            id = "1",
            author = "Admin",
            message = "Mensagem global"
        }
    }

    cb(communications)
end)

📌 getUserData
Frontend
fetchNui<IUserData>("getUserData", {}, fallback)
Backend
RegisterNUICallback("getUserData", function(data, cb)
    local user = {
        id = "steam:110000000000000",
        name = "Rodrigo Carioca",
        policeRank = "Soldado",
        avatarURL = "https://api.dicebear.com/8.x/bottts-neutral/svg?seed=rodrigo"
    }

    cb(user)
end)

📌 updateAllReports
SendNUIMessage({
    action = "updateAllReports",
    data = { ... }
})
useNuiEvent("updateAllReports", (data?: IReport[]) => {
  setRecentTickets(data ?? []);
});

📌 updateNewReport
SendNUIMessage({
    action = "updateNewReport",
    data = { ... }
})
useNuiEvent("updateNewReport", (data?: IReport) => {
  if (!data) return;
  setRecentTickets(prev => [...prev, data]);
});

📌 updateAllCommunications
SendNUIMessage({
    action = "updateAllCommunications",
    data = { ... }
})
useNuiEvent("updateAllCommunications", (data?: Communication[]) => {
  setCommunications(data ?? []);
});

📌 newCommunicationMessage
SendNUIMessage({
    action = "newCommunicationMessage",
    data = { ... }
})
useNuiEvent("newCommunicationMessage", (data?: Communication) => {
  if (!data) return;
  setCommunications(prev => [...prev, data]);
});

📌 updateUserData
SendNUIMessage({
    action = "updateUserData",
    data = { ... }
})
useNuiEvent("updateUserData", (data?: IUserData) => {
  if (!data) return;
  setUserData(data);
});


##TIPAGENS

type Coords = {
  x: number;
  y: number;
  z: number;
};

export interface IReport {
  id: string;
  createdBy: string;
  description: string;
  handledBy: string;
  coords: Coords;
}

export interface Communication {
  id: string;
  author: string;
  message: string;
}

export interface IUserData {
  name?: string,
  avatarURL?: string
  id: string
  policeRank: string
  inService?: boolean
}