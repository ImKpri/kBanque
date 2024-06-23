--ESX = nil
--TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX = exports["base"]:getSharedObject()

ESX.RegisterServerCallback('kBanque:getBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getAccount('bank').money)
end)

local function logTransaction(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    
    MySQL.Async.execute('INSERT INTO transactions (identifier, type, amount, date) VALUES (@identifier, @type, @amount, NOW())', {
        ['@identifier'] = identifier,
        ['@type'] = type,
        ['@amount'] = amount
    })
end

RegisterServerEvent('kBanque:depositMoney')
AddEventHandler('kBanque:depositMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', amount)
        TriggerClientEvent('esx:showNotification', source, "Vous avez déposé ~g~$" .. amount)
        logTransaction(source, 'deposit', amount)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent")
    end
end)

RegisterServerEvent('kBanque:withdrawMoney')
AddEventHandler('kBanque:withdrawMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        TriggerClientEvent('esx:showNotification', source, "Vous avez retiré ~g~$" .. amount)
        logTransaction(source, 'withdraw', amount)
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent sur votre compte bancaire")
    end
end)

ESX.RegisterServerCallback('kBanque:getTransactionHistory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    
    MySQL.Async.fetchAll('SELECT type, amount, date FROM transactions WHERE identifier = @identifier ORDER BY date DESC', {
        ['@identifier'] = identifier
    }, function(result)
        cb(result)
    end)
end)
