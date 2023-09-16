
local Result = nil
local NUI_status = false

RegisterNetEvent('qb-lockpick:client:openLockpick', function(callback, circles)
    lockpickCallback = callback
    exports['qb-lock']:StartLockPickCircle(total,circles) 
end)

function StartLockPickCircle(circles, seconds, callback)
    Result = nil
    NUI_status = true
    SendNUIMessage({
        action = 'start',
        value = circles,
		time = seconds,
    })
    while NUI_status do
        Wait(5)
        SetNuiFocus(NUI_status, false)
    end
    Wait(100)
    SetNuiFocus(false, false)
    lockpickCallback = callback
    return Result
end

RegisterNUICallback('fail', function()
    ClearPedTasks(PlayerPedId())
    Result = false
    Wait(100)
    NUI_status = false
    --print('fail')
end)

RegisterNUICallback('success', function()
	Result = true
	Wait(100)
	NUI_status = false
    SetNuiFocus(false, false)
    return Result
end)

exports('StartLockPickCircle', StartLockPickCircle)

-- CreateThread(function()
--     Wait(2000)
--     local seconds = math.random(9,12)
--     local circles = math.random(4,5)
--     local success = StartLockPickCircle(circles, seconds, success)
--     if success then
--         print'ss'
--     else
--         print'ff'
--     end
-- end)