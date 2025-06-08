local ESX = exports['es_extended']:getSharedObject()
local currentVehicle = nil
local inShop = false
local testDriveVeh = nil
local testDriveActive = false
local testDriveTimer = 0
local display = false

-- Initialize
CreateThread(function()
    local blip = AddBlipForCoord(Config.Shop.location.x, Config.Shop.location.y, Config.Shop.location.z)
    SetBlipSprite(blip, Config.Shop.blipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Shop.blipScale)
    SetBlipColour(blip, Config.Shop.blipColor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(_U('vehicle_shop'))
    EndTextCommandSetBlipName(blip)
end)

-- Shop Zone
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - Config.Shop.location)

        if distance < 2.0 then
            if not inShop then
                lib.showTextUI('[E] - ' .. _U('press_to_open'))
            end
            
            if distance < 2.0 then
                if IsControlJustReleased(0, 38) then -- E key
                    OpenVehicleShop()
                end
            end
        else
            lib.hideTextUI() -- Add this line to hide the Text UI when leaving the shop location
            if inShop then
                inShop = false
            end
            Wait(500)
        end
    end
end)

-- Timer thread pro kontrolu vzdálenosti během test drive
CreateThread(function()
    while true do
        Wait(1000)
        if testDriveActive and testDriveVeh then
            local playerPos = GetEntityCoords(PlayerPedId())
            local spawnPoint = Config.TestDrive.spawnPoint
            local distance = #(playerPos - spawnPoint)
            
            if distance > Config.TestDrive.maxDistance then
                lib.notify({
                    title = _U('test_drive'),
                    description = _U('max_distance_reached'),
                    type = 'error',
                    duration = 5000
                })
                
                DoScreenFadeOut(500)
                Wait(500)
                SetEntityCoords(testDriveVeh, spawnPoint.x, spawnPoint.y, spawnPoint.z)
                SetEntityHeading(testDriveVeh, 0.0)
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

function OpenVehicleShop()
    inShop = true
    lib.hideTextUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        categories = Config.Categories,
        vehicles = Config.Vehicles
    })
    display = true
end

function OpenColorPicker(vehicleData)
    SendNUIMessage({
        action = 'openColorPicker',
        vehicle = vehicleData
    })
end

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
    Wait(100)
    lib.hideTextUI()
end

function StartTestDrive(vehicle)
    if currentVehicle then
        DeleteVehicle(currentVehicle)
        currentVehicle = nil
    end

    lib.notify({
        title = _U('test_drive'),
        description = _U('test_drive_preparing'),
        type = 'info',
        duration = 2000
    })

    CloseVehicleShop()
    
    DoScreenFadeOut(500)
    Wait(500)

    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, Config.TestDrive.spawnPoint.x, Config.TestDrive.spawnPoint.y, Config.TestDrive.spawnPoint.z)
    Wait(500)

    ESX.Game.SpawnVehicle(vehicle.name, Config.TestDrive.spawnPoint, 0.0, function(veh)
        testDriveVeh = veh
        testDriveActive = true
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleNumberPlateText(veh, 'TEST' .. math.random(100, 999))
        
        Wait(500)
        DoScreenFadeIn(500)

        SendNUIMessage({
            action = 'startTestDriveTimer',
            time = Config.TestDrive.duration
        })

        testDriveTimer = Config.TestDrive.duration
        
        CreateThread(function()
            while testDriveTimer > 0 and testDriveActive do
                Wait(1000)
                testDriveTimer = testDriveTimer - 1
                
                if testDriveTimer == 10 then
                    lib.notify({
                        title = _U('test_drive'),
                        description = _U('test_drive_10sec'),
                        type = 'warning',
                        duration = 3000
                    })
                end
                
                if testDriveTimer == 0 then
                    EndTestDrive()
                end
            end
        end)

        lib.notify({
            title = _U('test_drive'),
            description = _U('test_drive_started'):format(Config.TestDrive.duration),
            type = 'success',
            duration = 5000
        })
    end)
end

function EndTestDrive()
    if testDriveVeh then
        testDriveActive = false
        
        lib.notify({
            title = _U('test_drive'),
            description = _U('teleporting_back'),
            type = 'info',
            duration = 2000
        })
        
        DoScreenFadeOut(500)
        Wait(500)

        DeleteVehicle(testDriveVeh)
        testDriveVeh = nil
        
        SetEntityCoords(PlayerPedId(), Config.Shop.location.x, Config.Shop.location.y, Config.Shop.location.z)
        SetEntityHeading(PlayerPedId(), Config.Shop.heading)
        
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
        lib.notify({
            title = _U('vehicle_shop'),
            description = _U('vehicle_returned'),
            type = 'info',
            duration = 3000
        })
    end
end

-- NUI Callbacks
RegisterNUICallback('startTestDrive', function(data, cb)
    if Config.TestDrive.enabled then
        StartTestDrive({name = data.model})
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
    end
    cb({})
end)

RegisterNUICallback('confirmPurchase', function(data, cb)
    print("confirmPurchase callback received: " .. json.encode(data))
    
    local vehicle = {
        name = data.model,
        color = data.color
    }
    
    -- Použít cenu z dat, pokud je k dispozici
    if data.price and tonumber(data.price) > 0 then
        vehicle.price = tonumber(data.price)
        print("Using price from data: $" .. vehicle.price)
    else
        -- Najít cenu vozidla v konfiguraci
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
        print("Found price in config: $" .. vehicle.price)
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
    cb({})
end)

function PurchaseVehicle(vehicle)
    -- Debug výpis
    print("Attempting to purchase vehicle: " .. vehicle.name .. " for $" .. (vehicle.price or "unknown"))
    
    ESX.TriggerServerCallback('esx_vehicleshop:buyVehicle', function(success)
        if success then
            -- Generovat náhodnou SPZ
            local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            local plate = ""
            for i = 1, 8 do
                local rand = math.random(#chars)
                plate = plate .. string.sub(chars, rand, rand)
            end
            
            -- Uložit vlastnictví vozidla přímo do garáže
            TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicle.name, plate, vehicle.color)
            
            if currentVehicle then
                DeleteVehicle(currentVehicle)
                currentVehicle = nil
            end
            
            -- Zobrazit notifikace o úspěšném nákupu a uložení do garáže
            lib.notify({
                title = _U('vehicle_shop'),
                description = _U('vehicle_purchased'),
                type = 'success',
                duration = 5000
            })
            
            Wait(1000)
            
            lib.notify({
                title = _U('vehicle_shop'),
                description = _U('vehicle_in_garage'),
                type = 'info',
                duration = 5000
            })
            
            -- Automaticky znovu otevřít menu autosalonu po zakoupení vozidla
            Wait(500)
            OpenVehicleShop()
        else
            -- Při nedostatku peněz zavřít color picker a znovu otevřít hlavní menu
            lib.notify({
                title = _U('vehicle_shop'),
                description = _U('not_enough_money'),
                type = 'error',
                duration = 3000
            })
            
            -- Resetovat NUI focus a znovu otevřít menu
            Wait(500)
            SetNuiFocus(false, false)
            OpenVehicleShop()
        end
    end, vehicle.name, vehicle.price)
end

-- Event handler pro force ukončení
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if testDriveVeh then
            EndTestDrive()
        end
        if currentVehicle then
            DeleteVehicle(currentVehicle)
        end
        if display then
            CloseVehicleShop()
        end
        lib.hideTextUI()
    end
end)