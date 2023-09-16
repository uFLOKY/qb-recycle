QBCore = exports['qb-core']:GetCoreObject()

GlobalState['RecycleConfig'] = {}

QBCore.Functions.CreateCallback('qb-recycle:GetConfig', function(source, cb)
	cb(Config)
end)

QBCore.Functions.CreateCallback('qb-recycle:CSecondRoute', function(source, cb)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local MyMeta = Player.PlayerData.metadata.recycle
    local answer = false

    if Config.Recycle.isOpen then 
        answer = true
    end
    cb(answer)
end)

QBCore.Functions.CreateCallback('qb-recycle:HasReloaded', function(source, cb)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local MyMeta = Player.PlayerData.metadata.recycle
    local answer = false

    if Config.Recycle.Players[Player.PlayerData.citizenid] then 
        Config.Recycle.Players[Player.PlayerData.citizenid].goodswith = Config.Recycle.Grades[MyMeta.grade].goodswith
        if Config.Recycle.isOpen then 
            Config.Recycle.Goods = Config.Recycle.Goods - Config.Recycle.Grades[MyMeta.grade].goodswith
            if Config.Recycle.Goods <= 0 then 
                Config.Recycle.isOpen = false
            end
            answer = true
        end
    end
    cb(answer)
end)

QBCore.Functions.CreateCallback('qb-recycle:CanTake', function(source, cb)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local MyMeta = Player.PlayerData.metadata.recycle

    if MyMeta then 
        if tonumber(MyMeta.amount) < Config.Recycle.Limit then 
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

local sec = 59

Citizen.CreateThread(function()
    while true do 
        Wait(1000)
        if not Config.Recycle.isOpen then 
            sec = sec - 1 
            if sec <= 0 then 
                sec = 59
                Config.Recycle.TimeOut = Config.Recycle.TimeOut - 1
                if Config.Recycle.TimeOut <= 0 then 
                    Config.Recycle.TimeOut = 59
                    Config.Recycle.isOpen = true 
                    Config.Recycle.Goods = 95000
                    CoolDownStarted = false
                end
            end
        end
        GlobalState['RecycleConfig'] = Config
    end
end)

RegisterNetEvent('qb-recycle:server:DoBail', function(veh, bool)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        local MyMeta = Player.PlayerData.metadata.recycle
        if bool then 
            if not Config.Recycle.Players[Player.PlayerData.citizenid] then 
                Player.Functions.RemoveMoney('bank', Config.Recycle.Depot, 'Goods-Logistic')
                Config.Recycle.Players[Player.PlayerData.citizenid] = {}
                Config.Recycle.Players[Player.PlayerData.citizenid].veh = veh
                Config.Recycle.Players[Player.PlayerData.citizenid].goodswith = Config.Recycle.Grades[MyMeta.grade].goodswith
                if Config.Recycle.isOpen then 
                    Config.Recycle.Goods = Config.Recycle.Goods - Config.Recycle.Grades[MyMeta.grade].goodswith
                    if Config.Recycle.Goods <= 0 then 
                        Config.Recycle.isOpen = false
                    end
                end
            end
        else
            if Config.Recycle.Players[Player.PlayerData.citizenid] then 
                Player.Functions.AddMoney('bank', Config.Recycle.Depot, 'Goods-Logistic', 'Goods-Logistic')
                Config.Recycle.Players[Player.PlayerData.citizenid] = nil
            end
        end
    end
end)

RegisterNetEvent('qb-recycle:server:DoRain', function(isPlus)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        local MyMeta = Player.PlayerData.metadata.recycle
        if MyMeta then 
            local Reward = Config.Recycle.Grades[MyMeta.grade]
            if isPlus then 
                MyMeta.amount = MyMeta.amount + (Reward.amount * 2)
            else
                MyMeta.amount = MyMeta.amount + Reward.amount
            end
            MyMeta.progress = MyMeta.progress + Reward.progress
            if Config.Recycle.Players[Player.PlayerData.citizenid] then 
                Config.Recycle.Players[Player.PlayerData.citizenid].goodswith = Config.Recycle.Players[Player.PlayerData.citizenid].goodswith - 100
                if Config.Recycle.Players[Player.PlayerData.citizenid].goodswith <= 0 then 
                    Config.Recycle.Players[Player.PlayerData.citizenid].goodswith = Config.Recycle.Grades[MyMeta.grade].goodswith
                    TriggerClientEvent('QBCore:Notify', src, 'Go back and pick new goods', 'system', 7500)
                    TriggerClientEvent('qb-recycle:client:ReloadEvent', src, true)
                else
                    TriggerClientEvent('qb-recycle:client:DoRouteAgain', src)
                end
            end
            if MyMeta.progress >= 100 then 
                MyMeta.progress = 1
                MyMeta.grade = MyMeta.grade + 1
                if MyMeta.grade >= 10 then 
                    MyMeta.grade = 10 
                end
            end
            Player.Functions.SetMetaData('recycle', MyMeta)
            TriggerClientEvent('QBCore:Notify', src, 'Goods have been delivered', 'success', 7500)
        end
    end
end)

RegisterNetEvent('qb-recycle:server:Goods', function(amount, item)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local update = false
    if Player then 
        local MyMeta = Player.PlayerData.metadata.recycle
        if MyMeta then 
            local GoodsData = Config.Recycle.Grades[MyMeta.grade]
            if amount >= 50 then 
                if MyMeta.amount >= amount then 
                    local devide = math.ceil(amount / #GoodsData.goods)
                    for k, v in pairs(GoodsData.goods) do 
                        if Player.Functions.AddItem(v, tonumber(devide), false, false, 'recycle-Goods') then 
                            MyMeta.amount = MyMeta.amount - tonumber(devide)
                            if MyMeta.amount <= 0 then 
                                MyMeta.amount = 0 
                            end
                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v], 'add', tonumber(devide))
                            update = true
                            Wait(800)
                        else
                            break
                            TriggerClientEvent('QBCore:Notify', src, 'Your inventory is full', 'error', 7500)
                        end
                    end
                    if update then 
                        Player.Functions.SetMetaData('recycle', MyMeta)
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, 'You don\'t have this amount of units', 'error', 7500)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'You must have at least 50 units', 'error', 7500)
            end
        end
    end
end)


-- QBCore.Commands.Add('closre', '', {}, false, function(source, args)
--     Config.Recycle.isOpen = not Config.Recycle.isOpen
-- end, 'god')

-- QBCore.Commands.Add('ssss', '', {}, false, function(source, args)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     local MyMeta = Player.PlayerData.metadata.recycle
--     MyMeta.amount = 0
--     MyMeta.grade = 8
--     Player.Functions.SetMetaData('recycle', MyMeta)
-- end, 'god')

QBCore.Commands.Add('relevel', 'Give Recycle Level', { { name = 'id', help = 'ID of player' }, { name = 'Level', help = 'Level' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local level = tonumber(args[2])
    if Player then
        if level then 
            local MyMeta = Player.PlayerData.metadata.recycle
            MyMeta.grade = level
            Player.Functions.SetMetaData('recycle', MyMeta)
            TriggerClientEvent('QBCore:Notify', src, 'Player with ID '..tonumber(args[1])..' is now on level '..level..'', 'success')
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You are now at level '..level..' for recycle job', 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player is not online', 'error')
    end
end, 'god')