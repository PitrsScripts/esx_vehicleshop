Config = {}

Config.Locale = 'cs'

-- Shop Location
Config.Shop = {
    location = vector3(-33.7, -1102.0, 26.4), -- PDM location
    heading = 70.0,
    blipSprite = 225,
    blipColor = 3,
    blipScale = 0.8
}


-- Test Drive Settings
Config.TestDrive = {
    enabled = true,
    duration = 20, -- seconds
    spawnPoint = vector3(979.6254, -2955.9900, 5.8956), -- kde se spawne auto při test drive
    maxDistance = 220.0, -- maximální vzdálenost od spawn pointu v metrech
    returnPoint = vector3(979.6254, -2955.9900, 5.8956) -- kam se hráč vrátí po test drive
}



-- Vehicle Categories
Config.Categories = {
    ['compacts'] = 'Compacts',
    ['super'] = 'Super',
    ['sports'] = 'Sports',
    ['muscle'] = 'Muscle',
    ['sedans'] = 'Sedans',
    ['coupes'] = 'Coupes',
    ['suvs'] = 'SUVs',
    ['offroad'] = 'Off-Road',
    ['vans'] = 'Vans',
    ['motorcycles'] = 'Motorcycles'
}

-- Vehicles Available for Purchase with external image URLs
Config.Vehicles = {
    ['compacts'] = {
        { model = 'asbo', label = 'Asbo', price = 12500, speed = '95 mph', seats = '2x', brand = 'Maxwell', image = 'https://i.pinimg.com/736x/63/87/09/638709ad1dd5c55f05b1d57b82d3878d.jpg' },
        { model = 'blista', label = 'Blista', price = 14000, speed = '98 mph', seats = '2x', brand = 'Dinka', image = 'https://i.pinimg.com/736x/36/cd/e6/36cde642e29fdb936ba7a3f8783083d.jpg' },
        { model = 'brioso', label = 'Brioso R/A', price = 15500, speed = '97 mph', seats = '2x', brand = 'Grotti', image = 'https://i.pinimg.com/736x/c2/90/89/c2908969b8d0824fb9d3bfe7469d614a.jpg' },
        { model = 'brioso2', label = 'Brioso 300', price = 16800, speed = '99 mph', seats = '2x', brand = 'Grotti', image = 'https://i.pinimg.com/736x/8a/25/46/8a25466f40d179b2b8cd7f147716b84b.jpg' },
        { model = 'brioso3', label = 'Brioso 300 Widebody', price = 18500, speed = '101 mph', seats = '2x', brand = 'Grotti', image = 'https://i.pinimg.com/736x/e8/69/9b/e8699bfbb2b35420ebde2fb42607d833.jpg' },
        { model = 'club', label = 'Club', price = 16000, speed = '97 mph', seats = '2x', brand = 'BF', image = 'https://i.pinimg.com/736x/16/bd/43/16bd43790ff2a15b9635f3ef307c321a.jpg' }
    },
    -- Add other categories and vehicles similarly
}

-- Shop Settings
Config.CommissionPercentage = 10 -- Commission for salespeople
Config.EnablePlayerManagement = false -- Set to true if you want job-based management
Config.ShopHours = {
    open = 6,  -- 6 AM
    close = 22 -- 10 PM
}
