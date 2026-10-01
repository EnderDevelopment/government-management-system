local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    RegisterNUICallback('close', function(data, cb)
        SetNuiFocus(false, false)
        cb({})
    end)

    RegisterNUICallback('apply', function(data, cb)
        TriggerServerEvent('government:apply', data.type)
        cb({})
    end)

    RegisterNUICallback('getLicenses', function(data, cb)
        ESX.TriggerServerCallback('government:getLicenses', function(licenses)
            cb(licenses)
        end)
    end)

    RegisterNUICallback('getApplications', function(data, cb)
        ESX.TriggerServerCallback('government:getApplications', function(applications)
            cb(applications)
        end)
    end)

    RegisterNUICallback('getEmployees', function(data, cb)
        ESX.TriggerServerCallback('government:getEmployees', function(employees)
            cb(employees)
        end)
    end)

    RegisterNUICallback('promote', function(data, cb)
        TriggerServerEvent('government:promote', data.identifier, data.department, data.rank)
        cb({})
    end)

    RegisterNUICallback('demote', function(data, cb)
        TriggerServerEvent('government:demote', data.identifier, data.department, data.rank)
        cb({})
    end)

    RegisterNUICallback('fire', function(data, cb)
        TriggerServerEvent('government:fire', data.identifier, data.department)
        cb({})
    end)

    RegisterNUICallback('issueLicense', function(data, cb)
        TriggerServerEvent('government:issueLicense', data.identifier, data.type)
        cb({})
    end)

    RegisterNUICallback('revokeLicense', function(data, cb)
        TriggerServerEvent('government:revokeLicense', data.identifier, data.type)
        cb({})
    end)

    RegisterNUICallback('approveApplication', function(data, cb)
        TriggerServerEvent('government:approveApplication', data.id, data.department, data.rank)
        cb({})
    end)

    RegisterNUICallback('rejectApplication', function(data, cb)
        TriggerServerEvent('government:rejectApplication', data.id)
        cb({})
    end)

    RegisterCommand('government', function()
        SetNuiFocus(true, true)
        SendNUIMessage({action = 'open'})
    end, false)

    RegisterNetEvent('government:notify')
    AddEventHandler('government:notify', function(message)
        ESX.ShowNotification(message)
    end)
end)