QBCore = exports['qb-core']:GetCoreObject()
PlayerData = QBCore.Functions.GetPlayerData()


local isInfoShowed = false
local CurrentLocation = nil
local LastLocation = nil
local WorkVeh = nil
local unloadBlip = nil
local isWorking = false
local canRealoadGoods = false
local ReloadBlip = nil
local isInRealodingArea = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnCompanyUpdate', function(CompanyInfo)
    PlayerData.company = CompanyInfo
end)

RegisterNetEvent('qb-recycle:client:ReloadEvent', function(bool)
    canRealoadGoods = bool
    isReloadEvent = true
    isLoop = true
    canRealoadGoods = false
    CreateReloadBlip()
end)

local function RouteBlip(RouteLocation)
    if RouteLocation then 
        if DoesBlipExist(unloadBlip) then
            RemoveBlip(unloadBlip)
        end
        unloadBlip = AddBlipForCoord(RouteLocation.coords.x, RouteLocation.coords.y, RouteLocation.coords.z)
        SetBlipSprite(unloadBlip, 1)
        SetBlipDisplay(unloadBlip, 2)
        SetBlipScale(unloadBlip, 1.0)
        SetBlipAsShortRange(unloadBlip, false)
        SetBlipColour(unloadBlip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Unload Area')
        EndTextCommandSetBlipName(unloadBlip)
        SetBlipRoute(unloadBlip, true)
    end
end

local function StartRoute(RouteLocation)
    if not RouteLocation then return end
    if RouteLocation then 
        local InRoad = true 
        local isLoading = false
        local TextSowed = false
        local isUnloading = false
        local sleep = 500
        RouteBlip(RouteLocation)
        Citizen.CreateThread(function()
            while InRoad do 
                local inRange = false
                local MyCoords = GetEntityCoords(PlayerPedId())
                local dis = #(MyCoords - RouteLocation.coords)
                if GetVehiclePedIsUsing(PlayerPedId()) == WorkVeh then 
                    if dis <= 20 then 
                        inRange = true
                        sleep = 5
                        DrawMarker(2, RouteLocation.coords.x, RouteLocation.coords.y, RouteLocation.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, false, false, false, false, false, false, false)
                        if dis <= 7 then 
                            if not TextSowed and not isLoading then 
                                TextSowed = true 
                                exports['qb-ui']:DrawText("[ E ] Unload Goods")
                            end
                            if IsControlJustPressed(0, 38) then 
                                if not isLoading then 
                                    isLoading = true 
                                    TextSowed = false
                                    exports['qb-ui']:HideText()
                                    QBCore.Functions.Progressbar("wood", "Unloading Goods", math.random(7000, 10000), false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- Done
                                        InRoad = false
                                        TriggerServerEvent('qb-recycle:server:DoRain', RouteLocation.plus)
                                        CurrentLocation = nil
                                        if DoesBlipExist(unloadBlip) then
                                            RemoveBlip(unloadBlip)
                                        end
                                    end, function() -- Cancel
                                        isLoading = false 
                                        QBCore.Functions.Notify("Cancled", "error")
                                    end)
                                    Wait(500)
                                end
                            end
                        end
                    end
                end
                if not inRange then 
                    sleep = 500
                    if TextSowed then 
                        TextSowed = false
                        exports['qb-ui']:HideText()
                    end
                end
                Wait(sleep)
            end
        end)
    end
end

local function GetLocation()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.metadata.recycle.grade <= 2 then 
        if CurrentLocation then 
            StartRoute(Config.Recycle.Main[CurrentLocation])
        else
            local Random = math.random(1, #Config.Recycle.Main)
            if Random ~= LastLocation then 
                CurrentLocation = Random
                LastLocation = Random
                StartRoute(Config.Recycle.Main[CurrentLocation])
            else
                Wait(1000)
                GetLocation()
            end
        end
    elseif PlayerData.metadata.recycle.grade >= 3 and PlayerData.metadata.recycle.grade <= 6 then 
        if CurrentLocation then 
            StartRoute(Config.Recycle.OuterLocations['sandy'][CurrentLocation])
        else
            local Random = math.random(1, #Config.Recycle.OuterLocations['sandy'])
            if Random ~= LastLocation then 
                CurrentLocation = Random
                LastLocation = Random
                StartRoute(Config.Recycle.OuterLocations['sandy'][CurrentLocation])
            else
                Wait(1000)
                GetLocation()
            end
        end
    elseif PlayerData.metadata.recycle.grade >= 7 then 
        if CurrentLocation then 
            StartRoute(Config.Recycle.OuterLocations['pol'][CurrentLocation])
        else
            local Random = math.random(1, #Config.Recycle.OuterLocations['pol'])
            if Random ~= LastLocation then 
                CurrentLocation = Random
                LastLocation = Random
                StartRoute(Config.Recycle.OuterLocations['pol'][CurrentLocation])
            else
                Wait(1000)
                GetLocation()
            end
        end
    end
end


local function ReloadEvent()
    canRealoadGoods = true
    local isLoading = false 
    Citizen.CreateThread(function()
        while canRealoadGoods do 
            if IsControlJustPressed(0, 38) and GetVehiclePedIsUsing(PlayerPedId()) == WorkVeh then 
                if isInRealodingArea then 
                    QBCore.Functions.TriggerCallback('qb-recycle:CSecondRoute', function(CSecondRoute)
                        if CSecondRoute then 
                            if not isLoading then 
                                isLoading = true 
                                exports['qb-ui']:HideText()
                                QBCore.Functions.Progressbar("wood", "Loading Goods", math.random(7000, 10000), false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    QBCore.Functions.TriggerCallback('qb-recycle:HasReloaded', function(HasReloaded)
                                        if HasReloaded then 
                                            GetLocation()
                                            Wait(200)
                                            exports['qb-ui']:HideText()
                                            canRealoadGoods = false
                                            if DoesBlipExist(ReloadBlip) then
                                                RemoveBlip(ReloadBlip)
                                            end
                                        else
                                            Wait(200)
                                            exports['qb-ui']:HideText()
                                            canRealoadGoods = false
                                        end
                                    end)
                                end, function() -- Cancel
                                    isLoading = false 
                                    QBCore.Functions.Notify("Cancled", "error")
                                end)
                                Wait(500)
                            end
                        else
                            Wait(200)
                            exports['qb-ui']:HideText()
                            canRealoadGoods = false
                        end
                    end)
                end
            end
            Wait(5)
        end
    end)
end

function CreateReloadBlip()
    if DoesBlipExist(ReloadBlip) then
        RemoveBlip(ReloadBlip)
    end
    ReloadBlip = AddBlipForCoord(837.59375,-1934.0469970703,28.875106811523)
    SetBlipSprite(ReloadBlip, 1)
    SetBlipDisplay(ReloadBlip, 2)
    SetBlipScale(ReloadBlip, 1.0)
    SetBlipAsShortRange(ReloadBlip, false)
    SetBlipColour(ReloadBlip, 33)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Reload Area')
    EndTextCommandSetBlipName(ReloadBlip)
    SetBlipRoute(ReloadBlip, true)
    ReloadEvent()
end

Citizen.CreateThread(function()
    local Recycle = AddBlipForCoord(vec3(845.10559082031,-1987.8270263672,29.301359176636))
    SetBlipSprite(Recycle, 478)
    SetBlipDisplay(Recycle, 4)
    SetBlipScale(Recycle, 0.6)
    SetBlipAsShortRange(Recycle, true)
    SetBlipColour(Recycle, 43)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Goods Logistic')
    EndTextCommandSetBlipName(Recycle)

    local RecyclePlace = BoxZone:Create(vector3(847.17, -1994.09, 29.3), 4.2, 7.2, {
        name="RecyclePlace",
        heading=354,
        --debugPoly=true,
        minZ=28.1,
        maxZ=31.5
    })
    RecyclePlace:onPlayerInOut(function(isPointInside)
        if isPointInside then
            isInfoShowed = true
            Citizen.CreateThread(function()
                while isInfoShowed do 
                    local GlobalConfig = GlobalState['RecycleConfig']
                    local isOpen = 'Closed'
                    if GlobalConfig.Recycle.isOpen then 
                        isOpen = 'Open'
                        if isInfoShowed then 
                            local Data = {
                                header = "Goods Logistic",
                                DataInfo = {
                                    [1] = "Warehouse Status : "..isOpen,
                                    [2] = "Remaining Goods : "..GlobalConfig.Recycle.Goods.." Units",
                                }
                            }
                            exports['qb-info']:ShowInfo(Data)
                        else
                            isInfoShowed = false
                            exports['qb-info']:HideInfo() 
                        end
                    else
                        if isInfoShowed then 
                            local Data = {
                                header = "Goods Logistic",
                                DataInfo = {
                                    [1] = "Warehouse Status : "..isOpen,
                                    [2] = "Opening In : "..GlobalConfig.Recycle.TimeOut.." Minutes",
                                }
                            }
                            exports['qb-info']:ShowInfo(Data)
                        else
                            isInfoShowed = false
                            exports['qb-info']:HideInfo() 
                        end
                    end
                    Wait(1000)
                end
            end)
        else
            isInfoShowed = false
            exports['qb-info']:HideInfo()
        end
    end)

    local ReroutePlace = BoxZone:Create(vector3(837.91, -1934.31, 28.97), 15.8, 10.2, {
        name="ReroutePlace",
        heading=355,
        --debugPoly=true,
        minZ=27.97,
        maxZ=31.97
    })
    ReroutePlace:onPlayerInOut(function(isPointInside)
        if isPointInside then
            if not WorkVeh then return end
            isInfoShowed = true
            if canRealoadGoods then 
                Citizen.CreateThread(function()
                    local isLoading = false
                    local TextSowed = false
                    isInRealodingArea = true
                    while isInfoShowed do 
                        if GetVehiclePedIsUsing(PlayerPedId()) == WorkVeh then 
                            local GlobalConfig = GlobalState['RecycleConfig']
                            local isOpen = 'Closed'
                            if GlobalConfig.Recycle.isOpen then 
                                isOpen = 'Open'
                                if isInfoShowed then 
                                    local Data = {
                                        header = "Goods Logistic",
                                        DataInfo = {
                                            [1] = "Warehouse Status : "..isOpen,
                                            [2] = "Remaining Goods : "..GlobalConfig.Recycle.Goods.." Units",
                                        }
                                    }
                                    exports['qb-info']:ShowInfo(Data)
                                else
                                    isInfoShowed = false
                                    exports['qb-info']:HideInfo() 
                                end
                                if not TextSowed and not isLoading then 
                                    TextSowed = true 
                                    exports['qb-ui']:DrawText("[ E ] Reload Goods")
                                end
                            else
                                if isInfoShowed then 
                                    local Data = {
                                        header = "Goods Logistic",
                                        DataInfo = {
                                            [1] = "Warehouse Status : "..isOpen,
                                            [2] = "Opening In : "..GlobalConfig.Recycle.TimeOut.." Minutes",
                                        }
                                    }
                                    exports['qb-info']:ShowInfo(Data)
                                else
                                    isInfoShowed = false
                                    exports['qb-info']:HideInfo() 
                                    TextSowed = true 
                                    exports['qb-ui']:DrawText("[ E ] Reload Goods")
                                end
                            end
                        else
                            isInfoShowed = false
                            exports['qb-info']:HideInfo() 
                            TextSowed = false
                            exports['qb-ui']:HideText()
                        end
                        Wait(1000)
                    end
                end)
            end
        else
            isInRealodingArea = false
            isInfoShowed = false
            exports['qb-info']:HideInfo()
            TextSowed = false
            exports['qb-ui']:HideText()
        end
    end)
end)

RegisterNetEvent('qb-recycle:client:openMenu', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    local recycleMenu = {}
    local GlobalConfig = GlobalState['RecycleConfig']
    local levelgoods = {}
    for k, v in pairs(GlobalConfig.Recycle.Grades[PlayerData.metadata['recycle']["grade"]].goods) do
        local itemInfo = QBCore.Shared.Items[v:lower()]
        local test = "&ensp;| &ensp;" ..itemInfo.label.. "&ensp;"
        levelgoods[#levelgoods + 1] = test
    end
    recycleMenu = {
        {
            header = "Goods Logistic",
            isMenuHeader = true,
        },
        {
            header = "Your Current Working Status is :",
            text = "Level : "..PlayerData.metadata['recycle']["grade"].." / 10 <br> Current Progress : "..PlayerData.metadata['recycle']["progress"].."% <br>You will have "..table.concat(levelgoods).." at this level",
            isMenuHeader = true,
        },
        {
            header = "Start Work",
            txt = "Pick up your vehicle and start work",
            params = {
                event = "qb-recycle:client:actions",
                args = {
                    action = 1
                }
            }
        },
        {
            header = "Stop Working / Return Vehicle",
            txt = "Finish Current Route",
            params = {
                event = "qb-recycle:client:actions",
                args = {
                    action = 2
                }
            }
        },
        {
            header = "Goods",
            txt = "Collect Your Goods You Have : "..PlayerData.metadata['recycle']["amount"].."",
            params = {
                event = "qb-recycle:client:actions",
                args = {
                    action = 3
                }
            }
        },
        {
            header = "Exit",
            params = {
                event = "qb-menu:closeMenu",
            }
        },
    }
    if #recycleMenu <= 0 then return end
    exports['qb-menu']:openMenu(recycleMenu)
end)

local isDoingShit = false

RegisterNetEvent('qb-recycle:client:actions', function(data)
    PlayerData = QBCore.Functions.GetPlayerData()
    local GlobalConfig = GlobalState['RecycleConfig']
    if data.action == 1 then 
        if isDoingShit then return end
        if not isWorking then 
            if GlobalConfig.Recycle.isOpen then 
                QBCore.Functions.TriggerCallback('qb-recycle:CanTake', function(CanTake)
                    if CanTake then 
                        isDoingShit = true
                        QBCore.Functions.Notify('Please wait we are preparing your vehicle', 'system', 5000)
                        local isAreaClear = false
                        local SpawnCoords = nil
                        for i=1, #Config.Recycle.Spawn, 1 do
                            local coords = vector3(Config.Recycle.Spawn[i].x, Config.Recycle.Spawn[i].y, Config.Recycle.Spawn[i].z)
                            if QBCore.Functions.SpawnClear(coords, 1) and not isAreaClear then 
                                SpawnCoords = vector4(Config.Recycle.Spawn[i].x, Config.Recycle.Spawn[i].y, Config.Recycle.Spawn[i].z, Config.Recycle.Spawn[i].h)
                                isAreaClear = true
                            end
                        end
                        if isAreaClear and SpawnCoords then 
                            if PlayerData.money.bank >= Config.Recycle.Depot then 
                                DoScreenFadeOut(800)
                                Wait(800)
                                if Config.Recycle.Grades[PlayerData.metadata.recycle.grade].veh then 
                                    Config.Recycle.Vehicle = Config.Recycle.Grades[PlayerData.metadata.recycle.grade].veh
                                end
                                QBCore.Functions.SpawnVehicle(Config.Recycle.Vehicle, function(veh)
                                    SetVehicleNumberPlateText(veh, "RECL"..tostring(math.random(1000, 9999)))
                                    SetEntityHeading(veh, SpawnCoords.w)
                                    exports['LegacyFuel']:SetFuel(veh, 100.0)
                                    SetEntityAsMissionEntity(veh, true, true)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                                    SetVehicleEngineOn(veh, true, true)
                                    local vehData = NetworkGetNetworkIdFromEntity(veh)
                                    TriggerServerEvent('qb-recycle:server:DoBail', vehData, true)
                                    WorkVeh = veh
                                    isWorking = true
                                end, SpawnCoords, true)
                                Wait(800)
                                DoScreenFadeIn(800)
                                isDoingShit = false
                                GetLocation()
                            else
                                QBCore.Functions.Notify('Note Enough Money, The Deposit Is $'..Config.Recycle.Depot..'', "error")
                            end
                        else
                            QBCore.Functions.Notify("We Can\'t Give You Your Vehicle Right Now", "error")
                        end
                    else
                        QBCore.Functions.Notify("You need to lower your goods amount at warehouse", "error")
                    end
                end)
            else
                QBCore.Functions.Notify('Goods warehouse is closed right now', 'error', 7500)
            end
        else
            QBCore.Functions.Notify('You are already working', 'error', 7500)
        end
    elseif data.action == 2 then 
        TriggerServerEvent('qb-recycle:server:DoBail', nil, false)
        if DoesBlipExist(unloadBlip) then
            RemoveBlip(unloadBlip)
        end
        if DoesBlipExist(ReloadBlip) then
            RemoveBlip(ReloadBlip)
        end
        if DoesEntityExist(WorkVeh) then
            local coords = GetEntityCoords(WorkVeh)
            if #(coords - vector3(840.13305664063,-1969.716796875,29.291612625122)) <= 200 then 
                DeleteEntity(WorkVeh)
            end
        end
        WorkVeh = nil
        isWorking = false
    elseif data.action == 3 then 
        if PlayerData.metadata.recycle.amount > 0 then 
            local dialog = exports['qb-input']:ShowInput({
                header = "Amount",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Please add amount", -- text you want to be displayed as a place holder
                        name = "amount", -- name of the input should be unique otherwise it might override
                        type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                        isRequired = true -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                    },
                },
            })
        
            if dialog ~= nil then
                if dialog.amount and tonumber(dialog.amount) > 0 then 
                    TriggerServerEvent('qb-recycle:server:Goods', tonumber(dialog.amount))
                end
            end
        else
            QBCore.Functions.Notify('You don\'t have goods right now', 'error', 5000)
        end
    end
end)

RegisterNetEvent('qb-recycle:client:picked', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = "Amount",
        submitText = "Submit",
        inputs = {
            {
                text = "Please add amount", -- text you want to be displayed as a place holder
                name = "amount", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = true -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        },
    })

    if dialog ~= nil then
        if dialog.amount and tonumber(dialog.amount) > 0 then 
            TriggerServerEvent('qb-recycle:server:Goods', tonumber(dialog.amount), data.item)
        end
    end
end)

RegisterNetEvent('qb-recycle:client:DoRouteAgain', function(data)
    Wait(1000)
    GetLocation()
end)