Config = {}

Config.Locale = "cs" -- cs,en,cn,de,es,hu,no,pl,ru,tr,vi

Config.Interaction = "ox_textui" -- Interaction Type (ox_textui,ox_target,jg_textui)
Config.SpeedUnit = "mph" -- Speed Unit (mph or kmh)


-- Shop Locations
Config.Shops = {
    car = {
        enabled = true,
            location = vector3(220.3054, -808.9489, 30.6720), -- PDM location (x, y, z)
        npc = {
            model = "a_m_y_business_03",
            sellNPC = {
                model = "a_m_y_business_02"
            }
        },
        sellPosition = vector3(-54.3091, -1092.4795, 26.4224), -- Position for vehicle selling
        sellPercent = 0.2, -- 60% of original price when selling
        testDrive = {
            enabled = true,
            duration = 20, -- seconds
            spawnPoint = vector4(979.6254, -2955.9900, 5.8956, 0.0), -- spawn point for test drive car
            maxDistance = 220.0, -- maximum distance from spawn point in meters
            useCustomPlate = true, -- whether to use custom plate during test drive
            plate = "TESTOVACIJIZDA", -- default plate for test drive
            plateFormat = "black" -- Vehicle plate color (white or black)
        },
        blip = {
            enabled = false,
            sprite = 225,
            color = 3,
            scale = 0.6,
            name = "Car Dealership" -- Custom blip name
        },
        categories = {'compacts', 'super', 'sports', 'muscle', 'sedans', 'coupes', 'suvs', 'offroad', 'vans', 'motorcycles'}
    },
    boat = {
        enabled = true,
        location = vector3(-878.2969, -1418.4821, 1.5954), -- Boat shop (x, y, z)
        npc = {
            model = "s_m_y_baywatch_01",
            sellNPC = {
                model = "s_m_y_baywatch_01"
            }
        },
        sellPosition = vector3(-872.5850, -1421.9098, 1.5954), -- Position for boat selling
        sellPercent = 0.5, -- 50% of original price when selling
        testDrive = {
            enabled = true,
            duration = 30, -- seconds
            spawnPoint = vector4(-877.8276, -1423.5698, 0.1024, 293.4141), -- spawn point for test drive boat
            maxDistance = 100.0, -- maximum distance from spawn point in meters
            useCustomPlate = true,
            plate = "TESTBOAT",
            plateFormat = "black" -- Vehicle plate color (white or black)
        },
        blip = {
            enabled = true,
            sprite = 410, -- Blip for boats
            color = 3,
            scale = 0.6,
            name = "Boat Shop"
        },
        categories = {'boats'}
    },
    air = {
        enabled = true,
        location = vector3(-34.7890, -1098.5178, 26.4224), -- Helicopter shop (x, y, z)
        npc = {
            model = "s_m_y_pilot_01",
            sellNPC = {
                model = "s_m_m_pilot_02"
            }
        },
        sellPosition = vector3(-42.8840, -1096.6154, 26.4224), -- Position for helicopter selling
        sellPercent = 0.4, -- 40% of original price when selling
        testDrive = {
            enabled = false,
            duration = 40, -- seconds
            spawnPoint = vector4(-724.61, -1444.08, 5.0, 135.0), -- spawn point for test drive helicopter
            maxDistance = 1000.0, -- maximum distance from spawn point in meters
            useCustomPlate = true,
            plate = "TESTHELI",
            plateFormat = "white" -- Vehicle plate color (white or black)
        },
        blip = {
            enabled = true,
            sprite = 43, -- Blip for helicopters
            color = 3,
            scale = 0.6,
            name = "Helicopter Shop"
        },
        categories = {'helicopters'}
    }
}


-- Marker Settings 
Config.Marker = {
    enabled = true,
    type = 21,
    size = vector3(0.8, 0.8, 0.8), -- Marker size (x, y, z)
    color = {r = 255, g = 255, b = 255, a = 100} -- Marker color (RGBA)
}

-- Vehicle Categories
Config.Categories = {
    ['compacts'] = 'Compacts', -- Compact cars category
    ['super'] = 'Super', -- Supercars category
    ['sports'] = 'Sports', -- Sports cars category
    ['muscle'] = 'Muscle', -- Muscle cars category
    ['sedans'] = 'Sedans', -- Sedans category
    ['coupes'] = 'Coupes', -- Coupes category
    ['suvs'] = 'SUVs', -- SUVs category
    ['offroad'] = 'Off-Road', -- Off-road vehicles category
    ['vans'] = 'Vans', -- Vans category
    ['motorcycles'] = 'Motorcycles', -- Motorcycles category
    ['boats'] = 'Boats', -- Boats category
    ['helicopters'] = 'Helicopters' -- Helicopters category
}


-- Color Vehicles 
Config.VehicleColourOptions = {
    { label = 'Black', hex = '#000000', colorIndex = 0 },
    { label = 'White', hex = '#FFFFFF', colorIndex = 111 },
    { label = 'Red', hex = '#FF0000', colorIndex = 27 },
    { label = 'Blue', hex = '#0000FF', colorIndex = 64 },
    { label = 'Green', hex = '#00FF00', colorIndex = 53 },
    { label = 'Yellow', hex = '#FFFF00', colorIndex = 88 },
    { label = 'Orange', hex = '#FFA500', colorIndex = 38 },
    { label = 'Purple', hex = '#800080', colorIndex = 145 },
    { label = 'Pink', hex = '#FFC0CB', colorIndex = 135 },
    { label = 'Gray', hex = '#808080', colorIndex = 5 }
}


-- Sound Settings
Config.Sounds = {
    enabled = true,
    purchase = {
        name = "WEAPON_PURCHASE", -- Sound name for purchase
        dict = "HUD_AMMO_SHOP_SOUNDSET" -- Sound dictionary
    }
}

-- Vehicles Available for Purchase with local image paths
Config.Vehicles = {
    ['compacts'] = {
        { model = 'asbo', label = 'Asbo', price = 12500, speed = 153, seats = '2', brand = 'Maxwell', image = 'img/vehicles/asbo.png' },
        { model = 'blista', label = 'Blista', price = 14000, speed = 158, seats = '2', brand = 'Dinka', image = 'img/vehicles/blista.png' },
        { model = 'brioso', label = 'Brioso R/A', price = 15500, speed = 156, seats = '2', brand = 'Grotti', image = 'img/vehicles/brioso.png' },
        { model = 'brioso2', label = 'Brioso 300', price = 16800, speed = 159, seats = '2', brand = 'Grotti', image = 'img/vehicles/brioso2.png' },
        { model = 'brioso3', label = 'Brioso 300 Widebody', price = 18500, speed = 163, seats = '2', brand = 'Grotti', image = 'img/vehicles/brioso3.png' },
        { model = 'club', label = 'Club', price = 16000, speed = 156, seats = '2', brand = 'BF', image = 'img/vehicles/club.png' },
        { model = 'kanjo', label = 'Kanjo', price = 15800, speed = 157, seats = '2', brand = 'Dinka', image = 'img/vehicles/kanjo.png' },
        { model = 'prairie', label = 'Prairie', price = 13500, speed = 155, seats = '2', brand = 'Bollokan', image = 'img/vehicles/prairie.png' },
        { model = 'panto', label = 'Panto', price = 11000, speed = 150, seats = '2', brand = 'Benefactor', image = 'img/vehicles/panto.png' },
        { model = 'issi2', label = 'Issi', price = 14500, speed = 154, seats = '2', brand = 'Weeny', image = 'img/vehicles/issi2.png' },
        { model = 'weevil', label = 'Weevil', price = 13200, speed = 152, seats = '2', brand = 'BF', image = 'img/vehicles/weevil.png' }
    },
    ['boats'] = {
        { model = 'dinghy', label = 'Dinghy', price = 25000, speed = 120, seats = '4', brand = 'Nagasaki', image = 'img/vehicles/dinghy.png' },
        { model = 'jetmax', label = 'Jetmax', price = 45000, speed = 140, seats = '4', brand = 'Shitzu', image = 'img/vehicles/jetmax.png' },
        { model = 'seashark', label = 'Seashark', price = 16000, speed = 130, seats = '2', brand = 'Speedophile', image = 'img/vehicles/seashark.png' },
        { model = 'speeder', label = 'Speeder', price = 55000, speed = 145, seats = '4', brand = 'Pegassi', image = 'img/vehicles/speeder.png' },
        { model = 'squalo', label = 'Squalo', price = 32000, speed = 135, seats = '4', brand = 'Shitzu', image = 'img/vehicles/squalo.png' },
        { model = 'toro', label = 'Toro', price = 65000, speed = 150, seats = '6', brand = 'Lampadati', image = 'img/vehicles/toro.png' }
    },
    ['helicopters'] = {
        { model = 'buzzard2', label = 'Buzzard', price = 500000, speed = 180, seats = '4', brand = 'Nagasaki', image = 'img/vehicles/buzzard2.png' },
        { model = 'frogger', label = 'Frogger', price = 450000, speed = 170, seats = '4', brand = 'Western', image = 'img/vehicles/frogger.png' },
        { model = 'havok', label = 'Havok', price = 350000, speed = 175, seats = '1', brand = 'Nagasaki', image = 'img/vehicles/havok.png' },
        { model = 'maverick', label = 'Maverick', price = 400000, speed = 160, seats = '4', brand = 'Buckingham', image = 'img/vehicles/maverick.png' },
        { model = 'seasparrow', label = 'Sea Sparrow', price = 550000, speed = 165, seats = '4', brand = 'Buckingham', image = 'img/vehicles/seasparrow.png' },
        { model = 'supervolito', label = 'SuperVolito', price = 750000, speed = 190, seats = '6', brand = 'Buckingham', image = 'img/vehicles/supervolito.png' },
        { model = 'swift', label = 'Swift', price = 800000, speed = 195, seats = '6', brand = 'Buckingham', image = 'img/vehicles/swift.png' }
    }
}