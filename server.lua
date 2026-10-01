local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Load government departments and ranks
local departments = Config.Departments
local ranks = Config.Ranks

-- Load government licenses
local licenses = Config.Licenses

-- Load government application types
local applications = Config.Applications

-- Load government administration settings
local admin = Config.Admin

-- Check if player is a government employee
function isGovernmentEmployee(identifier, department)
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM government_employees WHERE identifier = @identifier AND department = @department', {
        ['@identifier'] = identifier,
        ['@department'] = department
    })
    return result > 0
end

-- Check if player has a government license
function hasGovernmentLicense(identifier, type)
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM government_licenses WHERE identifier = @identifier AND type = @type', {
        ['@identifier'] = identifier,
        ['@type'] = type
    })
    return result > 0
end

-- Check if player has a government application
function hasGovernmentApplication(identifier, type)
    local result = MySQL.Sync.fetchScalar('SELECT COUNT(*) FROM government_applications WHERE identifier = @identifier AND type = @type', {
        ['@identifier'] = identifier,
        ['@type'] = type
    })
    return result > 0
end

-- Check if player has a government permission
function hasGovernmentPermission(identifier, department, permission)
    local result = MySQL.Sync.fetchScalar('SELECT rank FROM government_employees WHERE identifier = @identifier AND department = @department', {
        ['@identifier'] = identifier,
        ['@department'] = department
    })
    if result then
        local rank = ranks[result]
        if rank then
            for _, perm in ipairs(rank.permissions) do
                if perm == permission then
                    return true
                end
            end
        end
    end
    return false
end

-- Apply for a government position
RegisterServerEvent('government:apply')
AddEventHandler('government:apply', function(type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if not hasGovernmentApplication(identifier, type) then
        MySQL.Async.execute('INSERT INTO government_applications (identifier, type, status) VALUES (@identifier, @type, @status)', {
            ['@identifier'] = identifier,
            ['@type'] = type,
            ['@status'] = 'pending'
        }, function(rowsChanged)
            TriggerClientEvent('government:notify', source, 'Application submitted successfully')
        end)
    else
        TriggerClientEvent('government:notify', source, 'You already have a pending application')
    end
end)

-- Get government licenses for a player
ESX.RegisterServerCallback('government:getLicenses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchAll('SELECT type FROM government_licenses WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        local playerLicenses = {}
        for _, row in ipairs(result) do
            table.insert(playerLicenses, row.type)
        end
        cb(playerLicenses)
    end)
end)

-- Get government applications for a player
ESX.RegisterServerCallback('government:getApplications', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchAll('SELECT id, type, status FROM government_applications WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        cb(result)
    end)
end)

-- Get government employees for a department
ESX.RegisterServerCallback('government:getEmployees', function(source, cb, department)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if isGovernmentEmployee(identifier, department) then
        MySQL.Async.fetchAll('SELECT identifier, rank FROM government_employees WHERE department = @department', {
            ['@department'] = department
        }, function(result)
            cb(result)
        end)
    else
        cb({})
    end
end)

-- Promote a government employee
RegisterServerEvent('government:promote')
AddEventHandler('government:promote', function(targetIdentifier, department, rank)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if hasGovernmentPermission(identifier, department, 'promote') then
        local currentRank = MySQL.Sync.fetchScalar('SELECT rank FROM government_employees WHERE identifier = @identifier AND department = @department', {
            ['@identifier'] = targetIdentifier,
            ['@department'] = department
        })

        if currentRank then
            local currentRankIndex = 0
            for i, r in ipairs(departments[department].ranks) do
                if r == currentRank then
                    currentRankIndex = i
                    break
                end
            end

            if currentRankIndex < #departments[department].ranks then
                local newRank = departments[department].ranks[currentRankIndex + 1]
                MySQL.Async.execute('UPDATE government_employees SET rank = @rank WHERE identifier = @identifier AND department = @department', {
                    ['@identifier'] = targetIdentifier,
                    ['@department'] = department,
                    ['@rank'] = newRank
                }, function(rowsChanged)
                    TriggerClientEvent('government:notify', source, 'Employee promoted successfully')
                end)
            else
                TriggerClientEvent('government:notify', source, 'Employee is already at the highest rank')
            end
        else
            TriggerClientEvent('government:notify', source, 'Employee not found')
        end
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to promote employees')
    end
end)

-- Demote a government employee
RegisterServerEvent('government:demote')
AddEventHandler('government:demote', function(targetIdentifier, department, rank)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if hasGovernmentPermission(identifier, department, 'demote') then
        local currentRank = MySQL.Sync.fetchScalar('SELECT rank FROM government_employees WHERE identifier = @identifier AND department = @department', {
            ['@identifier'] = targetIdentifier,
            ['@department'] = department
        })

        if currentRank then
            local currentRankIndex = 0
            for i, r in ipairs(departments[department].ranks) do
                if r == currentRank then
                    currentRankIndex = i
                    break
                end
            end

            if currentRankIndex > 1 then
                local newRank = departments[department].ranks[currentRankIndex - 1]
                MySQL.Async.execute('UPDATE government_employees SET rank = @rank WHERE identifier = @identifier AND department = @department', {
                    ['@identifier'] = targetIdentifier,
                    ['@department'] = department,
                    ['@rank'] = newRank
                }, function(rowsChanged)
                    TriggerClientEvent('government:notify', source, 'Employee demoted successfully')
                end)
            else
                TriggerClientEvent('government:notify', source, 'Employee is already at the lowest rank')
            end
        else
            TriggerClientEvent('government:notify', source, 'Employee not found')
        end
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to demote employees')
    end
end)

-- Fire a government employee
RegisterServerEvent('government:fire')
AddEventHandler('government:fire', function(targetIdentifier, department)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if hasGovernmentPermission(identifier, department, 'fire') then
        MySQL.Async.execute('DELETE FROM government_employees WHERE identifier = @identifier AND department = @department', {
            ['@identifier'] = targetIdentifier,
            ['@department'] = department
        }, function(rowsChanged)
            TriggerClientEvent('government:notify', source, 'Employee fired successfully')
        end)
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to fire employees')
    end
end)

-- Issue a government license
RegisterServerEvent('government:issueLicense')
AddEventHandler('government:issueLicense', function(targetIdentifier, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if isGovernmentEmployee(identifier, 'Police') or isGovernmentEmployee(identifier, 'Fire') or isGovernmentEmployee(identifier, 'Health') then
        if not hasGovernmentLicense(targetIdentifier, type) then
            MySQL.Async.execute('INSERT INTO government_licenses (identifier, type) VALUES (@identifier, @type)', {
                ['@identifier'] = targetIdentifier,
                ['@type'] = type
            }, function(rowsChanged)
                TriggerClientEvent('government:notify', source, 'License issued successfully')
            end)
        else
            TriggerClientEvent('government:notify', source, 'Player already has this license')
        end
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to issue licenses')
    end
end)

-- Revoke a government license
RegisterServerEvent('government:revokeLicense')
AddEventHandler('government:revokeLicense', function(targetIdentifier, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if isGovernmentEmployee(identifier, 'Police') or isGovernmentEmployee(identifier, 'Fire') or isGovernmentEmployee(identifier, 'Health') then
        MySQL.Async.execute('DELETE FROM government_licenses WHERE identifier = @identifier AND type = @type', {
            ['@identifier'] = targetIdentifier,
            ['@type'] = type
        }, function(rowsChanged)
            TriggerClientEvent('government:notify', source, 'License revoked successfully')
        end)
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to revoke licenses')
    end
end)

-- Approve a government application
RegisterServerEvent('government:approveApplication')
AddEventHandler('government:approveApplication', function(id, department, rank)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if isGovernmentEmployee(identifier, department) then
        local application = MySQL.Sync.fetchAll('SELECT identifier FROM government_applications WHERE id = @id', {
            ['@id'] = id
        })

        if application[1] then
            local targetIdentifier = application[1].identifier
            MySQL.Async.execute('INSERT INTO government_employees (identifier, department, rank, salary) VALUES (@identifier, @department, @rank, @salary)', {
                ['@identifier'] = targetIdentifier,
                ['@department'] = department,
                ['@rank'] = rank,
                ['@salary'] = ranks[rank].salary
            }, function(rowsChanged)
                MySQL.Async.execute('UPDATE government_applications SET status = @status WHERE id = @id', {
                    ['@id'] = id,
                    ['@status'] = 'approved'
                }, function(rowsChanged)
                    TriggerClientEvent('government:notify', source, 'Application approved successfully')
                end)
            end)
        else
            TriggerClientEvent('government:notify', source, 'Application not found')
        end
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to approve applications')
    end
end)

-- Reject a government application
RegisterServerEvent('government:rejectApplication')
AddEventHandler('government:rejectApplication', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if isGovernmentEmployee(identifier, 'Police') or isGovernmentEmployee(identifier, 'Fire') or isGovernmentEmployee(identifier, 'Health') then
        MySQL.Async.execute('UPDATE government_applications SET status = @status WHERE id = @id', {
            ['@id'] = id,
            ['@status'] = 'rejected'
        }, function(rowsChanged)
            TriggerClientEvent('government:notify', source, 'Application rejected successfully')
        end)
    else
        TriggerClientEvent('government:notify', source, 'You do not have permission to reject applications')
    end
end)