_G.Triggers = {}

function Triggers:Client(eventName, playersTable, ...)
    local params = { ... }

    if type(playersTable) == 'table' then
        for playerSource in pairs(playersTable) do
            TriggerClientEvent(eventName, playerSource, table.unpack(params))
        end
    else
        local playerSource = playersTable

        TriggerClientEvent(eventName, playerSource, table.unpack(params))
    end
end

function Triggers:Server(eventName, playersTable, ...)
    local params = { ... }

    if type(playersTable) == 'table' then
        for playerSource in pairs(playersTable) do
            TriggerEvent(eventName, playerSource, table.unpack(params))
        end
    else
        local playerSource = playersTable

        TriggerEvent(eventName, playerSource, table.unpack(params))
    end
end