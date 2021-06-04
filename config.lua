Config = {}

Config.StandAlone = false -- !!Change this if you using a framework!! 
Config.UseItems = true -- Everything in the shop is an item and you need to use it. Commands are desable ;)



Config.Second = 1000


Config.UpdateTime = Config.Second * 10 -- Each 10 Seconds it updates every server.
Config.TemperaturePerUpdate = 0.6 -- Increase/decreases 0.6º per update (When the server get more fans it increases slower and decreases faster)

Config.HealthTakenPerUpdateHighHeath = 0.1 -- Takes 0.1% of health, when the server has less than 50º Celcius
Config.HealthTakenPerUpdateMidHeath = 1.5 -- Takes 1.5% of health, when the server tempature is between 50-80º Celcius
Config.HealthTakenPerUpdateLowHeath = 2.0 -- Takes 2.0% of health, when the server tempature is between 80-100º Celcius
Config.HealthTakenPerCloseExplosion = 20 -- Amount of health taken when close to a server that exploded

Config.CoinsPerUpdate = 0.0022 -- Amount of coins the server receive each update. PS: Dont use more than 4 decimals!
Config.CoinName = "MysteryCoin" -- Choose the name for your coin
Config.Currency = "$" -- I even let you choose a Currency for the html ;)
Config.Price = 1000 -- The price for each coin

Config.MaxServers = 3 -- The max of servers per player
Config.MaxFans = 3 -- The max of fans each machine
Config.MaxGPU = 3 -- The max of GPU's each machine

-- TriggerClientEvent("kofkof:UseGPU", source) | TriggerEvent to add a GPU to the server.
-- TriggerClientEvent("kofkof:UseFan", source) | TriggerEvent to add a FAN to the server.
-- TriggerClientEvent("kofkof:RepairServer", source) | TriggerEvent to repair the server.
-- TriggerClientEvent("kofkof:SpawnPlaceMonitor", source) | TriggerEvent to spawn a monitor.
-- TriggerClientEvent("kofkof:SpawnServer", source) | TriggerEvent to spawn a server.




Config.Products = {
    {label = "Serveur", price = "10000", itemname = "server", type="server"},
    {label = "Kit de réparation de serveur", price = "2000", itemname = "fixserver", type="fix"},
    {label = "GPU", price = "5000", itemname = "servergpu", type="gpu"},
    {label = "Ventilateur", price = "3000", itemname = "serverfan", type="fan"},
}



Config.GetFrameworkClient = function()
    ESX = nil
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end

Config.GetFrameworkServer = function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end


Config.GetPlayerItem = function(source, itemname)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.getInventoryItem(itemname).count
end

Config.GetPlayerMoney = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.getMoney()
end


Config.AddPlayerItem = function(source, itemname, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(itemname, amount)
end

Config.RemovePlayerItem = function(source, itemname, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.GetPlayerItem(source, itemname) >= amount then
        xPlayer.removeInventoryItem(itemname, amount)
    end
end

Config.AddPlayerMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addMoney(amount)
end

Config.RemovePlayerMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.GetPlayerMoney(source) >= amount then
        xPlayer.removeMoney(amount)
    end
end



--Les autres traductions sont dans le client (l.102 et l.127) et dans le ui.html
Config.msgs = {
    coinsamount = "~w~Portefeuille de crypto monnaie: ~g~",
    donthavemoney = "Vous ~r~n'avez pas~w~ cette somme d'argent. Vous avez besoin de ~y~",
    donthavecoins = "~w~Vous ~r~n'avez pas~w~ ce montant de MysteryCoin. Vous avez ~y~",
    invalidCoins = "~r~Montant de  MysteryCoin invalide~w~",
    coinsname = "~w~ MysteryCoin~w~",
    placingfan = "~g~Ajout d'un ventilateur...~w~",
    placedfan = "~g~Ventilateur ajouté et prêt à l'emploi!~w~",
    placinggpu = "~g~Ajout d'un GPU...~w~",
    placedgpu = "~g~GPU ajouté et prêt à l'emploi!~w~",
    repairing = "~y~Réparation du serveur...~w~",
    repaired = "~y~Serveur réparé...~w~",
    serveradded = "Serveur ~g~Ajouté~w~",
    monitoradded = "Ecran ~g~Ajouté~w~",
    maxservers = "Nombre maximal de serveurs ~r~Atteints~w~",
    maxmonitors = "Nombre maximal d'écrans ~r~Atteints~w~"
}