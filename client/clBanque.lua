--[[ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)]]--
ESX = exports["base"]:getSharedObject()

function KeyboardInput(textEntry, exampleText, maxStringLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", exampleText, "", "", "", maxStringLength)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.BankLocations) do
    local blip = AddBlipForCoord(v.x, v.y, v.z)
    SetBlipSprite(blip, 207)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.4)
    SetBlipColour(blip, 25)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Banque")
    EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        for k in pairs(Config.BankLocations) do
            
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local pos = Config.BankLocations
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)
            if dist <= 1.0 then
                wait = 0
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder à la banque")
                    if IsControlJustPressed(1,51) then
                        OpenBanking()
                    end
                end
            end
        Citizen.Wait(wait)
    end
end)

local distributorProps = { -870868698, -1126237515, -1364697528, 506770882 }
Citizen.CreateThread(function ()
    while GetResourceState("ox_target") ~= "started" do Citizen.Wait(0) end
    exports.ox_target:addModel(distributorProps, {
        {
            label = "Retirer",
            icon = "fa-solid fa-wallet",
            distance = 5.0,
            canInteract = function ()

                return true
            end,
            onSelect = function (data)
                local input = tonumber(KeyboardInput("Entrez le montant à retirer", "", 10))
                if input == nil then
                    return ESX.ShowNotification("~r~Le montant ne peut pas être nul")
                end

                if input <= 0 then
                    return ESX.ShowNotification("~r~Erreur lors de la transaction")
                end

                TriggerServerEvent('kBanque:withdrawMoney', input)
            end
        }, {
            label = "Déposer",
            icon = "fa-solid fa-wallet",
            distance = 5.0,
            canInteract = function ()

                return true
            end,
            onSelect = function (data)
                local input = tonumber(KeyboardInput("Entrez le montant à déposer", "", 10))
                if input == nil then
                    return ESX.ShowNotification("~r~Le montant ne peut pas être nul")
                end

                if input <= 0 then
                    return ESX.ShowNotification("~r~Erreur lors de la transaction")
                end

                TriggerServerEvent('kBanque:depositMoney', input)
            end
        }
    })
end)

local isBankOpen = false

OpenBanking = function()
    local balance = 0
    ESX.TriggerServerCallback('kBanque:getBalance', function(serverBalance)
        balance = serverBalance
        ESX.ShowNotification("Votre solde est de ~g~$" .. balance)
    end)
    FreezeEntityPosition(PlayerPedId(), true)
    local mainbk = RageUI.CreateMenu("Banque", "Interaction") 
    local historique = RageUI.CreateSubMenu(mainbk, "Banque", "Interaction") 
    
    RageUI.Visible(mainbk, true)
    
    Citizen.CreateThread(function()
        while RageUI.Visible(mainbk) do 
            Wait(0)
            RageUI.IsVisible(mainbk, function()
                RageUI.Info("Solde", {"~g~Montant :"}, {balance})
                RageUI.Button("Vérifier le solde", nil, {}, true, {
                    onSelected = function()
                        ESX.TriggerServerCallback('kBanque:getBalance', function(balance)
                            ESX.ShowNotification("Votre solde est de ~g~$" .. balance)
                        end)
                    end
                })
                RageUI.Button("Déposer de l'argent", nil, {}, true, {
                    onSelected = function()
                        local amount = tonumber(KeyboardInput("Entrez le montant à déposer", "", 10))
                        if amount > 0 then
                            TriggerServerEvent('kBanque:depositMoney', amount)
                        else
                            ESX.ShowNotification("Montant invalide")
                        end
                    end
                })
                RageUI.Button("Retirer de l'argent", nil, {}, true, {
                    onSelected = function()
                        local amount = tonumber(KeyboardInput("Entrez le montant à retirer", "", 10))
                        if amount > 0 then
                            TriggerServerEvent('kBanque:withdrawMoney', amount)
                        else
                            ESX.ShowNotification("Montant invalide")
                        end
                    end
                })
                RageUI.Line()
                RageUI.Button("Historique", nil, {RightLabel = '→→'}, true, {
                    onSelected = function()
                        ESX.TriggerServerCallback('kBanque:getTransactionHistory', function(transactions)
                            transactionHistory = transactions
                        end)
                    end
                }, historique)
            end)
            
            RageUI.IsVisible(historique, function()
                if transactionHistory then
                    for _, transaction in ipairs(transactionHistory) do
                        RageUI.Button(string.format('%s $%s - %s', transaction.type, transaction.amount, transaction.date), nil, {}, true, {})
                    end
                end
            end)

            if not RageUI.Visible(mainbk) and not RageUI.Visible(historique) then
                FreezeEntityPosition(PlayerPedId(), false)
                mainbk = RMenu:DeleteType('mainbk')
            end
        end
    end)
end
