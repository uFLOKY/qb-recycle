local QBCore = exports['qb-core']:GetCoreObject()



function ShowInfo(data)
    SendNUIMessage({
        action = "open",
        info = data,
    })
end

function HideInfo()
    SendNUIMessage({
        action = "close",
    })
end