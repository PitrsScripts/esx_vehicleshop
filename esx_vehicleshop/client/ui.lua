local function ShowNotification(message, type)
    lib.notify({
        title = 'Vehicle Shop',
        description = message,
        type = type or 'inform'
    })
end

RegisterNetEvent('esx_vehicleshop:notify')
AddEventHandler('esx_vehicleshop:notify', function(message, type)
    ShowNotification(message, type)
end)

exports('showNotification', ShowNotification)
