local db = {}

function db.fetchOwnedVehicles(owner, cb)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = ?', {owner}, function(result)
        cb(result)
    end)
end

function db.fetchOwnedVehicleByPlate(plate, cb)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = ?', {plate}, function(result)
        cb(result)
    end)
end

function db.fetchOwnedVehicleByPlateAndOwner(owner, plate, cb)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', {owner, plate}, function(result)
        cb(result)
    end)
end

function db.insertOwnedVehicle(owner, plate, vehicleProps, vehicleType, vehicleName, cb)
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, name) VALUES (?, ?, ?, ?, ?, ?)',
    {
        owner,
        plate,
        json.encode(vehicleProps),
        vehicleType,
        1,
        vehicleName
    }, function(rowsChanged)
        if cb then cb(rowsChanged) end
    end)
end

function db.updateOwnedVehicle(owner, vehicleProps, vehicleType, vehicleName, plate, cb)
    MySQL.Async.execute('UPDATE owned_vehicles SET owner = ?, vehicle = ?, type = ?, stored = ?, name = ? WHERE plate = ?',
    {
        owner,
        json.encode(vehicleProps),
        vehicleType,
        1,
        vehicleName,
        plate
    }, function(rowsChanged)
        if cb then cb(rowsChanged) end
    end)
end

function db.deleteOwnedVehicle(owner, plate, cb)
    MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = ? AND plate = ?', {owner, plate}, function(rowsChanged)
        if cb then cb(rowsChanged) end
    end)
end

return db
