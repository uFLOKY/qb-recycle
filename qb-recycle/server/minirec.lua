local QBCore = exports['qb-core']:GetCoreObject()

-- Events

RegisterNetEvent('qb-recycle:server:getItem', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  for _ = 1, math.random(1, Config.Mini.MaxItemsReceived), 1 do
    local randItem = Config.Mini.ItemTable[math.random(1, #Config.Mini.ItemTable)]
    local amount = math.random(Config.Mini.MinItemReceivedQty, Config.Mini.MaxItemReceivedQty)
    Player.Functions.AddItem(randItem, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add', amount)
    Wait(500)
  end
end)
