local ESX = exports['es_extended']:getSharedObject()
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local math_floor = math.floor
local math_random = math.random
local string_sub = string.sub
local table_insert = table.insert
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId
local DoesEntityExist = DoesEntityExist
local SetEntityCoords = SetEntityCoords
local SetEntityHeading = SetEntityHeading
local DeleteVehicle = DeleteVehicle
local Wait = Wait

local Locales = {}
local currentLocale = Config.Locale or 'cs'

local function loadLocale()
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. currentLocale .. '.lua')
    if localeFile then
        local env = {}
        env.Locales = {}
        local chunk, err = load(localeFile, 'locale', 't', env)
        if not chunk then
            return
        end
        local ok, err = pcall(chunk)
        if not ok then
            return
        end
        if env.Locales and env.Locales[currentLocale] then
            Locales = env.Locales[currentLocale]
        else
        end
    else
    end
end

loadLocale()

function _U(key)
    if Locales[key] then
        return Locales[key]
    else
        return key
    end
end

local currentVehicle = nil
local inShop = false
local testDriveVeh = nil
local testDriveActive = false
local testDriveTimer = 0
local display = false
local createdNPCs = {}
local wasNearShop = false
local wasNearSellPoint = false
local currentShopType = nil
local currentTestDriveShopType = nil
local testDriveThread = nil

Config.Shop = Config.Shops.car
Config.Blip = Config.Shops.car.blip
Config.NPC = Config.Shops.car.npc
Config.TestDrive = Config.Shops.car.testDrive


local resourceName = GetCurrentResourceName()
if resourceName ~= "esx_vehicleshop" then
    error("The script must be named 'esx_vehicleshop'")
end

local function loadModel(model)
    local modelHash = GetHashKey(model)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    return HasModelLoaded(modelHash)
end

local function createNPC(model, x, y, z, heading)
    if not loadModel(model) then
        return nil
    end
    local ped = CreatePed(4, GetHashKey(model), x, y, z, heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDefaultComponentVariation(ped)
    return ped
end

function ShowUI(text, icon)
    if Config.Interaction == 'ox_textui' then
        lib.showTextUI(text)
    elseif Config.Interaction == 'jg_textui' then
        exports['jg-textui']:DrawText(text)
    end
end

function HideUI()
    if Config.Interaction == 'ox_textui' then
        lib.hideTextUI()
    elseif Config.Interaction == 'jg_textui' then
        exports['jg-textui']:HideText()
    end
end

RegisterNetEvent('ox_lib:notify')
AddEventHandler('ox_lib:notify', function(data)
    if data ~= nil then
        lib.notify({
            title = data.title or _U('notification'),
            description = data.description or "",
            type = data.type or "info",
            position = data.position or "top-right",
            duration = data.duration or 5000,
            icon = data.icon or nil,
            style = data.style or nil
        })
    end
end)

CreateThread(function()
    for shopType, shop in pairs(Config.Shops) do
        if shop.enabled and shop.blip and shop.blip.enabled then
            local blip = AddBlipForCoord(shop.location.x, shop.location.y, shop.location.z)
            SetBlipSprite(blip, shop.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, shop.blip.scale)
            SetBlipColour(blip, shop.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(shop.blip.name)
            EndTextCommandSetBlipName(blip)
        end
    end
    
    for shopType, shopConfig in pairs(Config.Shops) do
        local npcConfig = shopConfig.npc
        if npcConfig and shopConfig.enabled and shopConfig.location and (Config.Interaction == 'ox_target' or (Config.Interaction ~= 'ox_textui' and Config.Interaction ~= 'jg_textui')) then
            local npc = createNPC(npcConfig.model, shopConfig.location.x, shopConfig.location.y, shopConfig.location.z - 1.0, 0.0)
            if npc then
                if Config.Interaction == 'ox_target' then
                    exports.ox_target:addLocalEntity(npc, {
                        {
                            name = 'vehicle_shop_npc_' .. shopType,
                            icon = shopType == 'car' and 'fas fa-car' or (shopType == 'boat' and 'fas fa-ship' or 'fas fa-helicopter'),
                            label = _U('press_to_open'),
                            onSelect = function()
                                OpenVehicleShop(shopType)
                            end
                        }
                    })
                end
                createdNPCs[shopType] = npc
            end

            if npcConfig.sellNPC then
                local sellNPC = createNPC(npcConfig.sellNPC.model, shopConfig.sellPosition.x, shopConfig.sellPosition.y, shopConfig.sellPosition.z - 1.0, 0.0)
                if sellNPC then
                    if Config.Interaction == 'ox_target' then
                        exports.ox_target:addLocalEntity(sellNPC, {
                            {
                                name = 'vehicle_sell_npc_' .. shopType,
                                icon = 'fas fa-dollar-sign',
                                label = _U('press_to_sell'),
                                onSelect = function()
                                    OpenSellMenu(shopType)
                                end
                            }
                        })
                    end
                    createdNPCs['sell_' .. shopType] = sellNPC
                end
            end
        end
    end
end)

-- Shop Zone
CreateThread(function()
    if Config.Interaction == 'ox_target' then
    else
        CreateThread(function()
        if not ((Config.Interaction == 'ox_textui' or Config.Interaction == 'jg_textui') and Config.Marker.enabled) then
            return
        end
        
        local markerLocations = {}
        local markerType = Config.Marker.type
        local markerSize = Config.Marker.size
        local markerColor = Config.Marker.color
        local playerLastPos = vector3(0,0,0)
        local sleepTime = 3000
        for shopType, shop in pairs(Config.Shops) do
            if shop.enabled then
                markerLocations[#markerLocations+1] = {
                    pos = vector3(shop.location.x, shop.location.y, shop.location.z),
                    x = shop.location.x,
                    y = shop.location.y,
                    z = shop.location.z - 0.3,
                    type = "shop"
                }
                if shop.sellPosition then
                    markerLocations[#markerLocations+1] = {
                        pos = vector3(shop.sellPosition.x, shop.sellPosition.y, shop.sellPosition.z),
                        x = shop.sellPosition.x,
                        y = shop.sellPosition.y,
                        z = shop.sellPosition.z - 0.3,
                        type = "sell",
                        shopType = shopType
                    }
                end
            end
        end
        
        while true do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local distMoved = #(coords - playerLastPos)
            if distMoved > 8.0 then
                playerLastPos = coords
                local nearAnyMarker = false
                for i=1, #markerLocations do
                    local marker = markerLocations[i]
                    local distance = #(coords - marker.pos)
                    if distance < 15.0 then
                        nearAnyMarker = true
                        break
                    end
                end
                sleepTime = nearAnyMarker and 100 or 3000
            end
            if sleepTime < 1000 then
                local anyMarkerDrawn = false
                
                for i=1, #markerLocations do
                    local marker = markerLocations[i]
                    local distance = #(coords - marker.pos)
                    
                    if distance < 10.0 then
                        anyMarkerDrawn = true
                        DrawMarker(
                            markerType,
                            marker.x, marker.y, marker.z,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            markerSize.x, markerSize.y, markerSize.z,
                            markerColor.r, markerColor.g, markerColor.b, markerColor.a,
                            false, true, 2, false, nil, nil, false
                        )
                    end
                end
                sleepTime = anyMarkerDrawn and 0 or 500
            end
            
            Wait(sleepTime)
        end
        end)
        local shopLocations = {}
        local sellLocations = {}
        local playerLastPos = vector3(0,0,0)
        local checkDistance = 50.0 
        local sleepTime = 2000 
        for shopType, shop in pairs(Config.Shops) do
            if shop.enabled then
                shopLocations[shopType] = vector3(shop.location.x, shop.location.y, shop.location.z)
                
                -- Přidáme lokace pro prodej vozidel
                if shop.sellPosition then
                    sellLocations[shopType] = {
                        pos = vector3(shop.sellPosition.x, shop.sellPosition.y, shop.sellPosition.z),
                        percent = shop.sellPercent or Config.SellPercent
                    }
                end
            end
        local playerLastPos = vector3(0,0,0)
        local checkDistance = 50.0 
        local sleepTime = 2000 
        local checkDistance = 50.0 
        local sleepTime = 2000 
        for shopType, shop in pairs(Config.Shops) do
            if shop.enabled then
                shopLocations[shopType] = vector3(shop.location.x, shop.location.y, shop.location.z)
                
                -- Přidáme lokace pro prodej vozidel
                if shop.sellPosition then
                    sellLocations[shopType] = {
                        pos = vector3(shop.sellPosition.x, shop.sellPosition.y, shop.sellPosition.z),
                        percent = shop.sellPercent or Config.SellPercent
                    }
                end
            end
        end
        
        while true do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            if #(coords - playerLastPos) > 5.0 then
                playerLastPos = coords
                local nearAnyShop = false
                local closestShop = nil
                local closestDist = 999.0
                for shopType, shopPos in pairs(shopLocations) do
                    local distance = #(coords - shopPos)
                    if distance < closestDist then
                        closestDist = distance
                        closestShop = shopType
                    end
                    if distance < 20.0 then
                        nearAnyShop = true
                        break
                    end
                end
                if not nearAnyShop then
                    sleepTime = 2000
                    if wasNearShop then
                        HideUI()
                        wasNearShop = false
                    end
                else
                    sleepTime = 500
                end
            end
            if sleepTime < 1000 then
                local isNearShop = false
                local isNearSellPoint = false
                local shopType = nil
                local sellShopType = nil
                for type, pos in pairs(shopLocations) do
                    if #(coords - pos) < 2.0 then
                        isNearShop = true
                        shopType = type
                        break
                    end
                end
                
                for type, data in pairs(sellLocations) do
                    if #(coords - data.pos) < 2.0 then
                        isNearSellPoint = true
                        sellShopType = type
                        break
                    end
                end
                
                if isNearShop then
                    if not wasNearShop or wasNearSellPoint then
                        local icon = shopType == 'car' and 'car' or (shopType == 'boat' and 'ship' or 'helicopter')
                        ShowUI('[E] - ' .. _U('press_to_open'), icon)
                        wasNearShop = true
                        wasNearSellPoint = false
                    end
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        OpenVehicleShop(shopType)
                    end
                    
                    sleepTime = 0
                elseif isNearSellPoint then
                    if not wasNearSellPoint or wasNearShop then
                        local icon = sellShopType == 'car' and 'car' or (sellShopType == 'boat' and 'ship' or 'helicopter')
                        ShowUI('[E] - ' .. _U('press_to_sell'), icon)
                        wasNearSellPoint = true
                        wasNearShop = false
                    end
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        OpenSellMenu(sellShopType)
                    end
                    
                    sleepTime = 0
                elseif wasNearShop or wasNearSellPoint then
                    HideUI()
                    wasNearShop = false
                    wasNearSellPoint = false
                    sleepTime = 500
                end
            end
            
            Wait(sleepTime)
        end
    end
end
end)

local testDriveThread = nil

function StartTestDriveMonitoring(shopType, spawnPoint, maxDistance)
    if testDriveThread then
        testDriveThread = nil
    end
    testDriveThread = CreateThread(function()
        local checkInterval = 1000
        local lastDistance = 0
        local spawnPos = vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z)
        
        while testDriveActive and testDriveVeh do
            Wait(checkInterval)
            
            if not DoesEntityExist(testDriveVeh) then
                break
            end
            
            local playerPos = GetEntityCoords(PlayerPedId())
            local distance = #(playerPos - spawnPos)
            if math.abs(distance - lastDistance) > 10.0 or distance > maxDistance * 0.7 then
                lastDistance = distance

                if distance > maxDistance * 0.9 then
                    checkInterval = 500
                elseif distance > maxDistance * 0.7 then
                    checkInterval = 1000
                else
                    checkInterval = 2000
                end
                
                if distance > maxDistance then
                    lib.notify({
                        title = _U('test_drive'),
                        description = _U('max_distance_reached'),
                        type = 'error',
                        duration = 5000
                    })
                    
                    DoScreenFadeOut(500)
                    Wait(500)
                    SetEntityCoords(testDriveVeh, spawnPoint.x, spawnPoint.y, spawnPoint.z)
                    SetEntityHeading(testDriveVeh, spawnPoint.w)
                    Wait(500)
                    DoScreenFadeIn(500)

                    lib.notify({
                        title = _U('test_drive'),
                        description = _U('test_drive_info'),
                        type = 'info',
                        duration = 5000
                    })
                end
            end
        end
    end)
end

function OpenVehicleShop(shopType)
    shopType = shopType or 'car'
    
    if not Config.Shops[shopType] or not Config.Shops[shopType].enabled then
        return
    end
    
    inShop = true
    currentShopType = shopType
    HideUI()
    SetNuiFocus(true, true)
    
    local shopCategories = {}
    for _, category in ipairs(Config.Shops[shopType].categories) do
        if Config.Categories[category] then
            shopCategories[category] = Config.Categories[category]
        end
    end
    local shopVehicles = {}
    for category, vehicles in pairs(Config.Vehicles) do
        if Config.Shops[shopType].categories and table.contains(Config.Shops[shopType].categories, category) then
            shopVehicles[category] = vehicles
        end
    end
    local testDriveEnabled = false
    if Config.Shops[shopType].testDrive and Config.Shops[shopType].testDrive.enabled then
        testDriveEnabled = true
    end
    
    SendNUIMessage({
        action = 'open',
        categories = shopCategories,
        vehicles = shopVehicles,
        speedUnit = Config.SpeedUnit,
        colours = Config.VehicleColourOptions,
        shopType = shopType,
        testDriveEnabled = testDriveEnabled
    })
    display = true
end


function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function OpenColorPicker(vehicleData)
    SendNUIMessage({
        action = 'openColorPicker',
        vehicle = vehicleData
    })
end

wasNearShop = false
wasNearSellPoint = false

function CloseVehicleShop()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
    if currentVehicle then
        DeleteVehicle(currentVehicle)
        currentVehicle = nil
    end
    display = false
    inShop = false
    wasNearShop = false
    Wait(100)
    HideUI()
end

function StartTestDrive(vehicle, shopType)
    shopType = shopType or currentShopType or 'car'
    
    if not Config.Shops[shopType] or not Config.Shops[shopType].enabled or not Config.Shops[shopType].testDrive.enabled then
lib.notify({
            title = _U('test_drive'),
            description = _U('test_drive_not_allowed'),
            type = 'error',
            duration = 3000
        })
        return
    end
    
    local testDriveConfig = Config.Shops[shopType].testDrive
    
    if currentVehicle then
        DeleteVehicle(currentVehicle)
        currentVehicle = nil
    end

    CloseVehicleShop()
    
    DoScreenFadeOut(500)
    Wait(500)

    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, testDriveConfig.spawnPoint.x, testDriveConfig.spawnPoint.y, testDriveConfig.spawnPoint.z)
    Wait(500)

    ESX.Game.SpawnVehicle(vehicle.name, testDriveConfig.spawnPoint, testDriveConfig.spawnPoint.w, function(veh)
        testDriveVeh = veh
        testDriveActive = true
        currentTestDriveShopType = shopType
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        
        if testDriveConfig.useCustomPlate then
            SetVehicleNumberPlateText(veh, testDriveConfig.plate)
        else
            SetVehicleNumberPlateText(veh, 'TEST' .. math.random(100, 999))
        end
        if testDriveConfig.plateFormat then
            local plateColorIndex = 0
            
            if testDriveConfig.plateFormat == "black" then
                plateColorIndex = 1 -- Černá
            elseif testDriveConfig.plateFormat == "white" then
                plateColorIndex = 0 -- Bílá
            elseif testDriveConfig.plateFormat == "blue" then
                plateColorIndex = 2 -- Modrá
            elseif testDriveConfig.plateFormat == "yellow" then
                plateColorIndex = 3 -- Žlutá
            elseif testDriveConfig.plateFormat == "orange" then
                plateColorIndex = 4 -- Oranžová
            elseif testDriveConfig.plateFormat == "green" then
            --
                plateColorIndex = 5 -- Zelená
            -- Podpora pro hexadecimální hodnoty
            elseif testDriveConfig.plateFormat:sub(1,1) == "#" then
                local hex = testDriveConfig.plateFormat:gsub("#",""):lower()
                
                if hex == "000000" then plateColorIndex = 1      -- Černá
                elseif hex == "ffffff" then plateColorIndex = 0  -- Bílá
                elseif hex == "0000ff" then plateColorIndex = 2  -- Modrá
                elseif hex == "ffff00" then plateColorIndex = 3  -- Žlutá
                elseif hex == "ffa500" then plateColorIndex = 4  -- Oranžová
                elseif hex == "00ff00" then plateColorIndex = 5  -- Zelená
                end
            end
            
            
            SetVehicleNumberPlateTextIndex(veh, plateColorIndex)
        end
        
        Wait(500)
        DoScreenFadeIn(500)

        SendNUIMessage({
            action = 'startTestDriveTimer',
            time = (Config.Shops[shopType] and Config.Shops[shopType].testDrive and Config.Shops[shopType].testDrive.duration) or 20
        })

        testDriveTimer = (Config.Shops[shopType] and Config.Shops[shopType].testDrive and Config.Shops[shopType].testDrive.duration) or 20

        StartTestDriveMonitoring(shopType, testDriveConfig.spawnPoint, testDriveConfig.maxDistance)
        
        CreateThread(function()
            while testDriveTimer > 0 and testDriveActive do
                Wait(1000)
                testDriveTimer = testDriveTimer - 1
                
                if testDriveTimer == 0 then
                    EndTestDrive()
                end
            end
        end)

                    lib.notify({
                        title = _U('test_drive'),
                        description = _U('test_drive_started'):format(testDriveConfig.duration),
                        type = 'success',
                        duration = 5000
                    })
    end)
end

function EndTestDrive()
    if testDriveVeh then
        local shopType = currentTestDriveShopType or 'car'
        local location = Config.Shops[shopType].location
        
        testDriveActive = false
        DoScreenFadeOut(500)
        Wait(500)

        DeleteVehicle(testDriveVeh)
        testDriveVeh = nil
        
        SetEntityCoords(PlayerPedId(), location.x, location.y, location.z)
        SetEntityHeading(PlayerPedId(), location.w)
        
        Wait(500)
        DoScreenFadeIn(500)
        
        SendNUIMessage({
            action = 'endTestDriveTimer'
        })
        
        lib.notify({
            title = _U('test_drive'),
            description = _U('test_drive_ended'),
            type = 'success',
            duration = 3000
        })

        Wait(500)
        currentTestDriveShopType = nil
    end
end

-- NUI Callbacks
RegisterNUICallback('startTestDrive', function(data, cb)
    local shopType = data.shopType or currentShopType or 'car'
    
    if Config.Shops[shopType] and Config.Shops[shopType].enabled and Config.Shops[shopType].testDrive.enabled then
        StartTestDrive({name = data.model}, shopType)
    else
        lib.notify({
            title = _U('test_drive'),
            description = _U('test_drive_disabled'),
            type = 'error',
            duration = 3000
        })
    end
    cb({})
end)

RegisterNUICallback('purchaseVehicle', function(data, cb)
    OpenColorPicker({
        model = data.model,
        name = data.model,
        price = data.price
    })
    cb({})
end)

RegisterNUICallback('updateVehicleColor', function(data, cb)
    if currentVehicle then
        SetVehicleCustomPrimaryColour(currentVehicle, data.color.r, data.color.g, data.color.b)
        SetVehicleCustomSecondaryColour(currentVehicle, data.color.r, data.color.g, data.color.b)

        if data.color.colorIndex ~= nil then
            SetVehicleColours(currentVehicle, data.color.colorIndex, data.color.colorIndex)
        end
    end
    cb({})
end)

RegisterNUICallback('confirmPurchase', function(data, cb)
    
    local vehicle = {
        name = data.model,
        color = data.color
    }

    if data.price and tonumber(data.price) > 0 then
        vehicle.price = tonumber(data.price)
    else
        local vehiclePrice = 0
        for _, category in pairs(Config.Vehicles) do
            for _, veh in ipairs(category) do
                if veh.model == data.model then
                    vehiclePrice = veh.price
                    break
                end
            end
            if vehiclePrice > 0 then break end
        end
        
        vehicle.price = vehiclePrice
    end
    
    PurchaseVehicle(vehicle)
    cb({})
end)

RegisterNUICallback('backFromColorPicker', function(data, cb)
    SendNUIMessage({
        action = 'closeColorPicker'
    })
    cb({})
end)

RegisterNUICallback('previewVehicle', function(data, cb)
    if currentVehicle then
        DeleteVehicle(currentVehicle)
    end
    cb({})
end)

RegisterNUICallback('close', function(data, cb)
    CloseVehicleShop()
    wasNearShop = false
    cb({})
end)



function PurchaseVehicle(vehicle)    
    ESX.TriggerServerCallback('esx_vehicleshop:buyVehicle', function(success)
        if success then
            local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            local plate = ""
            for i = 1, 8 do
                local rand = math.random(#chars)
                plate = plate .. string.sub(chars, rand, rand)
            end
            
            TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicle.name, plate, vehicle.color)
            
            if currentVehicle then
                DeleteVehicle(currentVehicle)
                currentVehicle = nil
            end
            
            if Config.Sounds.enabled then
                PlaySoundFrontend(-1, Config.Sounds.purchase.name, Config.Sounds.purchase.dict, false)
            end
            
            exports.ox_lib:notify({
                title = _U('vehicle_shop'),
                description = _U('vehicle_purchased') .. ' - SPZ: ' .. plate,
                type = 'success',
                duration = 5000
            })
            
            OpenVehicleShop(currentShopType)
        else
            lib.notify({
                title = _U('vehicle_shop'),
                description = _U('not_enough_money'),
                type = 'error',
                duration = 3000
            })
            
            Wait(500)
            SetNuiFocus(false, false)
            OpenVehicleShop()
        end
    end, vehicle.name, vehicle.price)
end

-- Předpřipravená tabulka cen podle třídy vozidla
local classPrices = {
    [0] = 25000, [1] = 40000, [2] = 70000, [3] = 60000, [4] = 100000,
    [5] = 120000, [6] = 150000, [7] = 200000, [8] = 15000, [9] = 60000,
    [10] = 80000, [11] = 40000, [12] = 35000, [13] = 1000, [14] = 120000,
    [15] = 600000, [16] = 1500000, [17] = 40000, [18] = 70000, [19] = 100000,
    [20] = 300000, [21] = 150000
}

function OpenSellMenu(shopType)
    local sellPercent = (Config.Shops[shopType] and Config.Shops[shopType].sellPercent) or Config.SellPercent or 0.6
    ESX.TriggerServerCallback('esx_vehicleshop:getOwnedVehicles', function(ownedVehicles)
        if #ownedVehicles == 0 then
            lib.notify({title = _U('vehicle_shop'), description = _U('no_owned_vehicles'), type = 'error', duration = 3000})
            return
        end
        local vehicleOptions = {}
        local vehiclePrices = {}

        for i = 1, #ownedVehicles do
            local veh = ownedVehicles[i]
            local vehicleData = json.decode(veh.vehicle)
            local modelHash = vehicleData.model
            local modelName = GetDisplayNameFromVehicleModel(modelHash)
            local displayName = veh.name or modelName or "Unknown"
            local vehiclePrice = 0
            local vehicleCategory = nil

            -- Find vehicle price and category
            for categoryName, categoryVehicles in pairs(Config.Vehicles) do
                for _, v in ipairs(categoryVehicles) do
                    if v.model:lower() == modelName:lower() then
                        vehiclePrice = v.price
                        vehicleCategory = categoryName
                        break
                    end
                end
                if vehiclePrice > 0 then break end
            end

            -- Check if vehicle category is allowed in this shop
            if vehicleCategory and Config.Shops[shopType] and Config.Shops[shopType].categories then
                if not table.contains(Config.Shops[shopType].categories, vehicleCategory) then
                    goto continue
                end
            end

            local sellPrice = math.floor(vehiclePrice * sellPercent)
            vehiclePrices[i] = sellPrice

            table.insert(vehicleOptions, {
                value = i,
                label = displayName .. ' - ' .. veh.plate
            })

            ::continue::
        end

        local input1 = lib.inputDialog(_U('sell_vehicle'), {
            {
                type = 'select',
                label = _U('vehicle_model'),
                options = vehicleOptions,
                required = true
            }
        })

        if input1 and input1[1] then
            local selectedIndex = input1[1]
            local selectedVehicle = ownedVehicles[selectedIndex]
            local sellPrice = vehiclePrices[selectedIndex]

            local input2 = lib.inputDialog(_U('sell_vehicle'), {
                {
                    type = 'input',
                    label = _U('sell_price'),
                    default = tostring(sellPrice) .. " $",
                    required = true,
                    disabled = true
                },
                {
                    type = 'checkbox',
                    label = _U('confirm_sell'),
                    required = true
                }
            })

            if input2 and input2[1] then
                TriggerServerEvent('esx_vehicleshop:sellVehicle', selectedVehicle.plate, sellPrice, sellPercent)
                lib.notify({
                    title = _U('vehicle_shop'),
                    description = _U('vehicle_sold_for'):format(tostring(sellPrice)),
                    type = 'success',
                    duration = 3000
                })
            end
        end
    end)
end


function GetVehicleClassFromName(modelName)
    local modelHash = GetHashKey(modelName)
    local defaultClass = 0
    if IsModelInCdimage(modelHash) then
        local tempVeh = nil
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            local timeout = 0
            while not HasModelLoaded(modelHash) and timeout < 100 do
                Wait(10)
                timeout = timeout + 1
            end
        end
        
        if HasModelLoaded(modelHash) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            tempVeh = CreateVehicle(modelHash, playerCoords.x + 500.0, playerCoords.y + 500.0, -100.0, 0.0, false, false)
            
            if DoesEntityExist(tempVeh) then
                local vehicleClass = GetVehicleClass(tempVeh)
                DeleteVehicle(tempVeh)
                SetModelAsNoLongerNeeded(modelHash)
                return vehicleClass
            end
            
            SetModelAsNoLongerNeeded(modelHash)
        end
    end
    return defaultClass
end






