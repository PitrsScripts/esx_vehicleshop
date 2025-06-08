local ESX = exports['es_extended']:getSharedObject()

-- Initialize database
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `owned_vehicles` (
            `owner` varchar(60) NOT NULL,
            `plate` varchar(12) NOT NULL,
            `vehicle` longtext NOT NULL,
            `type` VARCHAR(20) NOT NULL DEFAULT 'car',
            `job` VARCHAR(20) NULL DEFAULT NULL,
            `stored` TINYINT(1) NOT NULL DEFAULT '1',
            PRIMARY KEY (`plate`)
        )
    ]])
end)

-- Buy vehicle callback
ESX.RegisterServerCallback('esx_vehicleshop:buyVehicle', function(source, cb, model, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Debug výpis
    print(('[^2INFO^7] Player %s attempting to buy vehicle %s for $%s'):format(xPlayer.identifier, model, price or "unknown"))
    
    -- Pokud cena není zadána, najdi ji v konfiguraci
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
        print(('[^1ERROR^7] Vehicle price not found for model %s'):format(model))
        cb(false)
        return
    end
    
    print(('[^2INFO^7] Final price for %s: $%s, Player money: $%s'):format(model, price, xPlayer.getMoney()))
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        print(('[^2SUCCESS^7] Player %s purchased vehicle %s for $%s'):format(xPlayer.identifier, model, price))
        cb(true)
    else
        print(('[^1ERROR^7] Player %s does not have enough money to buy %s ($%s)'):format(xPlayer.identifier, model, price))
        -- Odstraněna notifikace ze serveru, bude pouze z klienta
        cb(false)
    end
end)

-- Set vehicle owned event
RegisterServerEvent('esx_vehicleshop:setVehicleOwned')
AddEventHandler('esx_vehicleshop:setVehicleOwned', function(model, plate, color)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Připravit data vozidla bez tuningu
    local vehicleProps = {
        model = model,
        plate = plate,
        stored = true
    }
    
    -- Přidat barvu, pokud je k dispozici
    if color then
        vehicleProps.color1 = color
        vehicleProps.color2 = color
    end
    
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)',
        {
            xPlayer.identifier,
            plate,
            json.encode(vehicleProps),
            'car',
            1  -- Vozidlo je uloženo v garáži
        },
        function(rowsChanged)
            if rowsChanged then
                print(('[^2INFO^7] Vehicle %s purchased by %s and stored in garage with upgrades'):format(model, xPlayer.identifier))
            else
                print(('[^1ERROR^7] Failed to save vehicle purchase for %s'):format(xPlayer.identifier))
            end
        end
    )
end)

-- Get vehicle price
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

