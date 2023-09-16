local QBCore = exports['qb-core']:GetCoreObject()
local carryPackage = nil
local packageCoords = nil
local onDuty = false

-- zone check

local entranceTargetID = 'entranceTarget'
local isInsideEntranceZone = false
local entranceZone = nil

local exitTargetID = 'exitTarget'
local isInsideExitZone = false
local exitZone = nil

local deliveryTargetID = 'deliveryTarget'
local isInsideDeliveryZone = false
local deliveryZone = nil

local dutyTargetID = 'dutyTarget'
local isInsideDutyZone = false
local dutyZone = nil

local pickupTargetID = 'pickupTarget'
local isInsidePickupZone = false
local pickupZone = nil
local insideObj = {}

-- Functions

local function DestroyPickupTarget()
  if not pickupZone then
    return
  end
  
  if Config.Mini.UseTarget then
    exports['qb-target']:RemoveZone(pickupTargetID)
    pickupZone = nil
  else
    pickupZone:destroy()
    pickupZone = nil
    isInsidePickupZone = false
  end
end

local function RegisterEntranceTarget()
  local coords = vector3(Config.Mini.OutsideLocation.x, Config.Mini.OutsideLocation.y, Config.Mini.OutsideLocation.z)

  if Config.Mini.UseTarget then
    entranceZone = exports['qb-target']:AddBoxZone(entranceTargetID, coords, 1, 4, {
      name = entranceTargetID,
      heading = 44.0,
      minZ = Config.Mini.OutsideLocation.z - 1.0,
      maxZ = Config.Mini.OutsideLocation.z + 2.0,
      debugPoly = false,
    }, {
      options = {
        {
          type = 'client',
          event = 'qb-recyclejob:client:target:enterLocation',
          label = 'Enter Warehouse',
        },
      },
      distance = 1.0
    })
  else
    entranceZone = BoxZone:Create(coords, 1, 4, {
      name = entranceTargetID,
      heading = 44.0,
      minZ = Config.Mini.OutsideLocation.z - 1.0,
      maxZ = Config.Mini.OutsideLocation.z + 2.0,
      debugPoly = false
    })

    entranceZone:onPlayerInOut(function(isPointInside)
      if isPointInside then
        exports['qb-ui']:DrawText('[E] Enter Warehouse', 'left')
      else
        exports['qb-ui']:HideText()
      end

      isInsideEntranceZone = isPointInside
    end)
  end
end

local function RegisterExitTarget()
  local coords = vector3(Config.Mini.InsideLocation.x, Config.Mini.InsideLocation.y, Config.Mini.InsideLocation.z)
    
  if Config.Mini.UseTarget then
    exitZone = exports['qb-target']:AddBoxZone(exitTargetID, coords, 1, 4, {
      name = exitTargetID,
      heading = 270,
      minZ = Config.Mini.InsideLocation.z - 1.0,
      maxZ = Config.Mini.InsideLocation.z + 2.0,
      debugPoly = false,
    }, {
      options = {
        {
          type = 'client',
          event = 'qb-recyclejob:client:target:exitLocation',
          label = 'Exit Warehouse',
        },
      },
      distance = 1.0
    })
  else
    exitZone = BoxZone:Create(coords, 1, 4, {
      name = exitTargetID,
      heading = 270,
      minZ = Config.Mini.InsideLocation.z - 1.0,
      maxZ = Config.Mini.InsideLocation.z + 2.0,
      debugPoly = false
    })

    exitZone:onPlayerInOut(function(isPointInside)
      if isPointInside then
        exports['qb-ui']:DrawText('[E] Exit Warehouse', 'left')
      else
        exports['qb-ui']:HideText()
      end

      isInsideExitZone = isPointInside
    end)
  end
end

local function DestroyExitTarget()
  if not exitZone then
    return
  end

  if Config.Mini.UseTarget then
    exports['qb-target']:RemoveZone(exitTargetID)
    exitZone = nil
  else
    exitZone:destroy()
    exitZone = nil
    isInsideExitZone = false
  end
end

local function GetDutyTargetText()
  local text = onDuty and '[E] Clock Out' or '[E] Clock In'
  return text
end

local function RegisterDutyTarget()
  local coords = vector3(Config.Mini.DutyLocation.x, Config.Mini.DutyLocation.y, Config.Mini.DutyLocation.z)
  
  if Config.Mini.UseTarget then
    dutyZone = exports['qb-target']:AddBoxZone(dutyTargetID, coords, 1, 1, {
      name = dutyTargetID,
      heading = 270,
      minZ = Config.Mini.DutyLocation.z - 2.0,
      maxZ = Config.Mini.DutyLocation.z + 1.0,
      debugPoly = false,
    }, {
      options = {
        {
          type = 'client',
          event = 'qb-recyclejob:client:target:toggleDuty',
          label = GetDutyTargetText(),
        },
      },
      distance = 1.0
    })
  else
    dutyZone = BoxZone:Create(coords, 1, 1, {
      name = dutyTargetID,
      heading = 270,
      minZ = Config.Mini.DutyLocation.z - 2.0,
      maxZ = Config.Mini.DutyLocation.z + 1.0,
      debugPoly = false
    })
  
    dutyZone:onPlayerInOut(function(isPointInside)
      if isPointInside then
        exports['qb-ui']:DrawText(GetDutyTargetText(), 'left')
      else
        exports['qb-ui']:HideText()
      end

      isInsideDutyZone = isPointInside
    end)
  end
end

local function DestroyDutyTarget()
  if not dutyZone then
    return
  end

  if Config.Mini.UseTarget then
    exports['qb-target']:RemoveZone(dutyTargetID)
    dutyZone = nil
  else
    dutyZone:destroy()
    dutyZone = nil
    isInsideDutyZone = false
  end
end

local function RefreshDutyTarget()
  DestroyDutyTarget()
  RegisterDutyTarget()
end


local function RegisterDeliveyTarget()
  local coords = vector3(Config.Mini.DropLocation.x, Config.Mini.DropLocation.y, Config.Mini.DropLocation.z)

  if Config.Mini.UseTarget then
    deliveryZone = exports['qb-target']:AddBoxZone(deliveryTargetID, coords, 1, 1, {
      name = deliveryTargetID,
      heading = 270,
      minZ = Config.Mini.DropLocation.z - 2.0,
      maxZ = Config.Mini.DropLocation.z + 1.0,
      debugPoly = false,
    }, {
      options = {
        {
          type = 'client',
          event = 'qb-recyclejob:client:target:dropPackage',
          label = 'Hand In Package',
        },
      },
      distance = 1.0
    })
  else
    deliveryZone = BoxZone:Create(coords, 3, 3, {
      name = deliveryTargetID,
      heading = 270,
      minZ = Config.Mini.DropLocation.z - 2.0,
      maxZ = Config.Mini.DropLocation.z + 1.0,
      debugPoly = false
    })
  
    deliveryZone:onPlayerInOut(function(isPointInside)
      if isPointInside and carryPackage then
        exports['qb-ui']:DrawText('[E] Hand In Package', 'left')
      else
        exports['qb-ui']:HideText()
      end

      isInsideDeliveryZone = isPointInside
    end)
  end
end

local function DestroyDeliveryTarget()
  if not deliveryZone then
    return
  end

  if Config.Mini.UseTarget then
    exports['qb-target']:RemoveZone(deliveryTargetID)
    deliveryZone = nil
  else
    deliveryZone:destroy()
    deliveryZone = nil
    isInsideDeliveryZone = false
  end
end

local function DestoryInsideZones()
  DestroyPickupTarget()
  DestroyExitTarget()
  DestroyDutyTarget()
  DestroyDeliveryTarget()
end

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Wait(5)
  end
end

local function ScrapAnim()
  local time = 5
  loadAnimDict('mp_car_bomb')
  TaskPlayAnim(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, false, false, false)
  local openingDoor = true
  
  CreateThread(function()
    while openingDoor do
      TaskPlayAnim(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 3.0, 3.0, -1, 16, 0, 0, 0, 0)
      Wait(1000)
      time = time - 1
      if time <= 0 then
        openingDoor = false
        StopAnimTask(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
      end
    end
  end)
end

local function GetRandomPackage()
  packageCoords = Config.Mini.PickupLocations[math.random(1, #Config.Mini.PickupLocations)]
  RegisterPickupTarget(packageCoords)
end

local function PickupPackage()
  local pos = GetEntityCoords(PlayerPedId(), true)
  RequestAnimDict('anim@heists@box_carry@')
  while (not HasAnimDictLoaded('anim@heists@box_carry@')) do
    Wait(7)
  end
  TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
  RequestModel(Config.Mini.PickupBoxModel)
  while not HasModelLoaded(Config.Mini.PickupBoxModel) do
    Wait(0)
  end
  local object = CreateObject(Config.Mini.PickupBoxModel, pos.x, pos.y, pos.z, true, true, true)
  AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
  carryPackage = object
end

local function DropPackage()
  ClearPedTasks(PlayerPedId())
  DetachEntity(carryPackage, true, true)
  DeleteObject(carryPackage)
  carryPackage = nil
end

local function SetLocationBlip()
  local RecycleBlip = AddBlipForCoord(Config.Mini.OutsideLocation.x, Config.Mini.OutsideLocation.y, Config.Mini.OutsideLocation.z)
  SetBlipSprite(RecycleBlip, 478)
  SetBlipColour(RecycleBlip, 4)
  SetBlipScale(RecycleBlip, 0.5)
  SetBlipAsShortRange(RecycleBlip, true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString('Recycle Center')
  EndTextCommandSetBlipName(RecycleBlip)
end

local function buildInteriorDesign()
  for k, pickuploc in pairs(Config.Mini.PickupLocations) do
    local model = GetHashKey(Config.Mini.WarehouseObjects[math.random(1, #Config.Mini.WarehouseObjects)])
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end
    local obj = CreateObject(model, pickuploc.x, pickuploc.y, pickuploc.z, false, true, true)
    insideObj[k] = obj
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
  end
end

local function EnterLocation()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do
    Wait(10)
  end
  SetEntityCoords(PlayerPedId(), Config.Mini.InsideLocation.x, Config.Mini.InsideLocation.y, Config.Mini.InsideLocation.z)
  buildInteriorDesign()
  DoScreenFadeIn(500)

  isInsidePickupZone = false
  isInsideExitZone = false
  isInsideDutyZone = false
  isInsideEntranceZone = false

  DestoryInsideZones()
  RegisterExitTarget()
  RegisterDutyTarget()
end

local function ExitLocation()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do
    Wait(10)
  end
  SetEntityCoords(PlayerPedId(), Config.Mini.OutsideLocation.x, Config.Mini.OutsideLocation.y, Config.Mini.OutsideLocation.z + 1)
  DoScreenFadeIn(500)

  onDuty = false
  isInsidePickupZone = false
  isInsideExitZone = false
  isInsideDutyZone = false
  isInsideEntranceZone = false

  DestoryInsideZones()

  if carryPackage then
    DropPackage()
  end
  if insideObj then 
    for k, v in pairs(insideObj) do
      if DoesEntityExist(v) then 
        DeleteEntity(v)
        insideObj[k] = nil
      end
    end
  end
end

function RegisterPickupTarget(coords)
  local targetCoords = vector3(coords.x, coords.y, coords.z)

  if Config.Mini.UseTarget then
    pickupZone = exports['qb-target']:AddBoxZone(pickupTargetID, targetCoords, 4, 1.5, {
      name = pickupTargetID,
      heading = coords.h,
      minZ = coords.z - 1.0,
      maxZ = coords.z + 2.0,
      debugPoly = false,
    }, {
      options = {
        {
          type = 'client',
          event = 'qb-recyclejob:client:target:pickupPackage',
          label = 'Get Package',
        },
      },
      distance = 1.0
    })
  else
    pickupZone = BoxZone:Create(targetCoords, 4, 1.5, {
      name = pickupTargetID,
      heading = coords.h,
      minZ = coords.z - 1.0,
      maxZ = coords.z + 2.0,
      debugPoly = false
    })

    pickupZone:onPlayerInOut(function(isPointInside)
      if isPointInside then
        exports['qb-ui']:DrawText('[E] Get Package', 'left')
      else
        exports['qb-ui']:HideText()
      end

      isInsidePickupZone = isPointInside
    end)
  end
end

local function DrawPackageLocationBlip()
  if not Config.Mini.DrawPackageLocationBlip then
    return
  end

  DrawMarker(2, packageCoords.x, packageCoords.y, packageCoords.z + 3, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, false, 2, true, nil, nil, false)
end

-- Events

RegisterNetEvent('qb-recyclejob:client:target:enterLocation', function()
  EnterLocation()
end)

RegisterNetEvent('qb-recyclejob:client:target:exitLocation', function()
  ExitLocation()
end)

RegisterNetEvent('qb-recyclejob:client:target:toggleDuty', function()
  onDuty = not onDuty
  if onDuty then
    QBCore.Functions.Notify('You Have Been Clocked In', 'success')
    GetRandomPackage()
  else
    QBCore.Functions.Notify('You Have Clocked Out', 'error')
    DestroyPickupTarget()
  end

  if carryPackage then
    DropPackage()
  end

  RefreshDutyTarget()
  DestroyDeliveryTarget()
end)

RegisterNetEvent('qb-recyclejob:client:target:pickupPackage', function()
  if not pickupZone or carryPackage then
    return
  end

  if not Config.Mini.UseTarget and not isInsidePickupZone then
    return
  end

  QBCore.Functions.Progressbar('pickup_reycle_package', 'Picking up the package', Config.Mini.PickupActionDuration, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true
    }, {}, {}, {}, function()
      packageCoords = nil
      ClearPedTasks(PlayerPedId())
      PickupPackage()
      DestroyPickupTarget()
      RegisterDeliveyTarget()
    end)
end)

RegisterNetEvent('qb-recyclejob:client:target:dropPackage', function()
  if not carryPackage or not deliveryZone then
    return
  end

  if not Config.Mini.UseTarget and not isInsideDeliveryZone then
    return
  end

  DropPackage()
  ScrapAnim()
  DestroyDeliveryTarget()
  QBCore.Functions.Progressbar('deliver_reycle_package', 'Unpacking the package', Config.Mini.DeliveryActionDuration, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true
    }, {}, {}, {}, function()
      -- Done
      StopAnimTask(PlayerPedId(), 'mp_car_bomb', 'car_bomb_mechanic', 1.0)
      TriggerServerEvent('qb-recycle:server:getItem')
      GetRandomPackage()
  end)
end)

-- Threads

CreateThread(function()
  local sleep = 500

  while not LocalPlayer.state.isLoggedIn do
    -- do nothing
    Wait(sleep)
  end

  SetLocationBlip()
  RegisterEntranceTarget()

  if Config.Mini.UseTarget then
    if not Config.Mini.DrawPackageLocationBlip then
      return
    end

    while true do
      sleep = 500

      if onDuty and packageCoords and not carryPackage then
        sleep = 0
        DrawPackageLocationBlip()
      end

      Wait(sleep)
    end
  else
    while true do
      sleep = 500
      
      if isInsideEntranceZone then
        sleep = 0
        if IsControlJustReleased(0, 38) then
          exports['qb-ui']:KeyPressed()
          Wait(500)
          TriggerEvent('qb-recyclejob:client:target:enterLocation')
          exports['qb-ui']:HideText()
        end
      end
      
      if isInsideExitZone then
        sleep = 0
        if IsControlJustReleased(0, 38) then
          exports['qb-ui']:KeyPressed()
          Wait(500)
          TriggerEvent('qb-recyclejob:client:target:exitLocation')
          exports['qb-ui']:HideText()
        end
      end

      if isInsideDutyZone then
        sleep = 0
        if IsControlJustReleased(0, 38) then
          exports['qb-ui']:KeyPressed()
          Wait(500)
          TriggerEvent('qb-recyclejob:client:target:toggleDuty')
          exports['qb-ui']:HideText()
        end
      end

      if onDuty then
        if isInsidePickupZone and not carryPackage then
          sleep = 0
          if IsControlJustReleased(0, 38) then
            exports['qb-ui']:KeyPressed()
            Wait(500)
            TriggerEvent('qb-recyclejob:client:target:pickupPackage')
            exports['qb-ui']:HideText()
          end
        elseif packageCoords and not carryPackage then
          sleep = 0
          DrawPackageLocationBlip()
        end

        if isInsideDeliveryZone and carryPackage then
          sleep = 0
          if IsControlJustReleased(0, 38) then
            exports['qb-ui']:KeyPressed()
            Wait(500)
            TriggerEvent('qb-recyclejob:client:target:dropPackage')
            exports['qb-ui']:HideText()
          end
        end
      end
      
      Wait(sleep)
    end
  end
end)
