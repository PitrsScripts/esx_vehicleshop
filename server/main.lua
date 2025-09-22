local ESX = exports['es_extended']:getSharedObject()

local db = require 'server.db'

ESX.RegisterServerCallback('esx_vehicleshop:buyVehicle', function(source, cb, model, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not price or price == 0 then
        for _, category in pairs(Config.Vehicles) do
            for _, vehicle in ipairs(category) do
                if vehicle.model == model then
                    price = vehicle.price
                    break
                end
            end
            if price and price > 0 then break end
        end
    end
    
    if not price or price == 0 then
        cb(false)
        return
    end
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        cb(true)
    else
        cb(false)
    end
end)

function GetVehicleTypeByModel(model)
    local vehicleType = 'car'
    
    for _, boat in ipairs(Config.Vehicles['boats'] or {}) do
        if boat.model == model then
            return 'boat'
        end
    end
    
    for _, heli in ipairs(Config.Vehicles['helicopters'] or {}) do
        if heli.model == model then
            return 'air'
        end
    end
    
    return vehicleType
end

RegisterServerEvent('esx_vehicleshop:setVehicleOwned')
AddEventHandler('esx_vehicleshop:setVehicleOwned', function(model, plate, color)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local vehicleProps = {
        model = tonumber(model) or GetHashKey(model),
        plate = plate,
        plateIndex = 0,
        bodyHealth = 1000,
        engineHealth = 1000,
        tankHealth = 1000,
        fuelLevel = 100,
        dirtLevel = 0,
        oilLevel = 8,
        color1 = 0,
        color2 = 0,
        pearlescentColor = 0,
        interiorColor = 0,
        dashboardColor = 0,
        wheelColor = 0,
        wheelSize = 1.0,
        wheelWidth = 1.0,
        wheels = 0,
        windowTint = -1,
        xenonColor = 255,
        neonEnabled = {false, false, false, false},
        neonColor = {255, 0, 255},
        extras = {},
        tyreSmokeColor = {255, 255, 255},
        modSpoilers = -1,
        modFrontBumper = -1,
        modRearBumper = -1,
        modSideSkirt = -1,
        modExhaust = -1,
        modFrame = -1,
        modGrille = -1,
        modHood = -1,
        modFender = -1,
        modRightFender = -1,
        modRoof = -1,
        modEngine = -1,
        modBrakes = -1,
        modTransmission = -1,
        modHorns = -1,
        modSuspension = -1,
        modArmor = -1,
        modTurbo = false,
        modSmokeEnabled = false,
        modXenon = false,
        modFrontWheels = -1,
        modBackWheels = -1,
        modPlateHolder = -1,
        modVanityPlate = -1,
        modTrimA = -1,
        modOrnaments = -1,
        modDashboard = -1,
        modDial = -1,
        modDoorSpeaker = -1,
        modSeats = -1,
        modSteeringWheel = -1,
        modShifterLeavers = -1,
        modAPlate = -1,
        modSpeakers = -1,
        modTrunk = -1,
        modHydrolic = -1,
        modNitrous = -1,
        modCustomTiresF = false,
        modCustomTiresR = false,
        driftTyres = false,
        livery = -1,
        windows = {4, 5},
        doors = {},
        tyres = {},
        bulletProofTyres = true
    }
    
    if color then
        local colorPrimary = color.colorIndex or 0
        local colorSecondary = color.colorIndex or 0
        
        vehicleProps.color1 = colorPrimary
        vehicleProps.color2 = colorSecondary
        vehicleProps.pearlescentColor = colorPrimary
        vehicleProps.wheelColor = 0
        vehicleProps.paintType1 = 0
        vehicleProps.paintType2 = 0
        vehicleProps.interiorColor = 0
        vehicleProps.dashboardColor = 0
        
        vehicleProps.customPrimaryColor = {r = color.r, g = color.g, b = color.b}
        vehicleProps.customSecondaryColor = {r = color.r, g = color.g, b = color.b}
    end
    
    local vehicleName = model
    
    if type(vehicleProps.model) == 'string' then
        vehicleProps.model = tonumber(GetHashKey(vehicleProps.model))
    end
    
    db.fetchOwnedVehicleByPlate(plate, function(result)
        if result and #result > 0 then
            local vehicleType = 'car'
            
            for _, boat in ipairs(Config.Vehicles['boats'] or {}) do
                if boat.model == model then
                    vehicleType = 'boat'
                    break
                end
            end
            
            if vehicleType == 'car' then
                for _, heli in ipairs(Config.Vehicles['helicopters'] or {}) do
                    if heli.model == model then
                        vehicleType = 'air'
                        break
                    end
                end
            end
            
            db.updateOwnedVehicle(xPlayer.identifier, vehicleProps, vehicleType, vehicleName, plate, function(rowsChanged)
            end)
        else
            local vehicleType = 'car'
            
            for _, boat in ipairs(Config.Vehicles['boats'] or {}) do
                if boat.model == model then
                    vehicleType = 'boat'
                    break
                end
            end
            
            if vehicleType == 'car' then
                for _, heli in ipairs(Config.Vehicles['helicopters'] or {}) do
                    if heli.model == model then
                        vehicleType = 'air'
                        break
                    end
                end
            end
            
            db.insertOwnedVehicle(xPlayer.identifier, plate, vehicleProps, vehicleType, vehicleName, function(rowsChanged)
            end)
        end
    end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getVehiclePrice', function(source, cb, model)
    local price = nil
    
    for _, category in pairs(Config.Vehicles) do
        for _, vehicle in ipairs(category) do
            if vehicle.name == model then
                price = vehicle.price
                break
            end
        end
        if price then break end
    end
    
    cb(price or 0)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getOwnedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    db.fetchOwnedVehicles(xPlayer.identifier, function(result)
        cb(result)
    end)
end)

RegisterServerEvent('esx_vehicleshop:sellVehicle')
AddEventHandler('esx_vehicleshop:sellVehicle', function(plate, price, sellPercent)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    db.fetchOwnedVehicleByPlateAndOwner(xPlayer.identifier, plate, function(result)
        if result and #result > 0 then
            db.deleteOwnedVehicle(xPlayer.identifier, plate, function(rowsChanged)
                if rowsChanged > 0 then
                    xPlayer.addMoney(price)
                else
                    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                        title = _U('vehicle_shop'),
                        description = _U('vehicle_sale_failed'),
                        type = 'error',
                        duration = 3000
                    })
                end
            end)
        else
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                title = _U('vehicle_shop'),
                description = _U('not_your_vehicle'),
                type = 'error',
                duration = 3000
            })
        end
    end)
end)
