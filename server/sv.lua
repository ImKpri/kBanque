--ESX = nil
--TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX = exports["base"]:getSharedObject()

ESX.RegisterServerCallback('kBanque:getBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getAccount('bank').money)
end)

RegisterServerEvent('kBanque:depositMoney')
AddEventHandler('kBanque:depositMoney', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', amount)
        TriggerClientEvent('esx:showNotification', source, "Vous avez déposé ~g~$" .. amount)
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
    else
        TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d'argent sur votre compte bancaire")
    end
end)