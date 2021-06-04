RegisterNetEvent('kofkof:giveCoinSTART')

AddEventHandler('kofkof:giveCoinSTART', function(source)

	TriggerClientEvent('kofkof:getCoinSTART', source)

end)





ESX = nil



if Config.StandAlone == false then

    Config.GetFrameworkServer()

end





RegisterNetEvent("kofkof:GetMachines")

AddEventHandler('kofkof:GetMachines', function(source)

    MySQL.Async.fetchAll("SELECT * FROM MysteryCryptoMining WHERE owner = @owner", {['@owner'] = GetLicensse(source)}, function(Machines)

        if Machines[1] == nil then

            MySQL.Async.execute("INSERT INTO MysteryCryptoMining (owner) VALUE (@owner)",

            {

                ['@owner']   = GetLicensse(source),

            }, function (rowsChanged)

            end)

        end

    end)

    MySQL.Async.fetchAll("SELECT machine FROM MysteryCryptoMining", {}, function(Machines)

        local machinestable = {}

        if Machines[1] ~= nil then

            for _, Machine in pairs(Machines[1]) do 

                local machineinset = json.decode(Machine)

                if machineinset ~= nil then

                    table.insert(machinestable, machineinset)

                end

            end

        else

            Machines={}

        end



        TriggerClientEvent("kofkof:GetMachinesCallBack", source, machinestable, GetLicensse(source))

    end)

end)



RegisterNetEvent("kofkof:CreateMachine")

AddEventHandler('kofkof:CreateMachine', function(source, machine)

    MySQL.Async.execute("UPDATE MysteryCryptoMining SET machine = @machine WHERE owner = @owner",

    {

        ['@owner']   = GetLicensse(source),

        ['@machine']   = json.encode(machine)

    }, function (rowsChanged)

    end)

end)





RegisterNetEvent("kofkof:UpdateMachine")

AddEventHandler('kofkof:UpdateMachine', function(source, machine)

    MySQL.Async.execute("UPDATE MysteryCryptoMining SET machine = @machine WHERE owner = @owner",

        {

            ['@owner'] = GetLicensse(source),

            ['@machine'] = json.encode(machine)

        }

    )

end)



RegisterNetEvent("kofkof:DeleteMachine")

AddEventHandler('kofkof:DeleteMachine', function(source)

    MySQL.Async.execute("DELETE FROM MysteryCryptoMining WHERE owner = @owner",
        {
            ['@owner'] = GetLicensse(source)
        }
    )
end)



RegisterNetEvent("kofkof:sendcartserver")

AddEventHandler('kofkof:sendcartserver', function(source, Cart, allprice)

    if Config.StandAlone == false then

        if Config.GetPlayerMoney(source) >= allprice then
            Config.RemovePlayerMoney(source, allprice)

            for _, Item in pairs(Cart) do 

                if Config.UseItems == false then

                    TriggerClientEvent("kofkof:AddProductToMachine", source, Item.itemname)

                elseif Config.UseItems == true then

                    Config.AddPlayerItem(source, Item.itemname, 1)

                end

            end

        end

    elseif Config.StandAlone == true then

        for _, Item in pairs(Cart) do 

            if Config.UseItems == false then

                TriggerClientEvent("kofkof:AddProductToMachine", source, Item.itemname)

            elseif Config.UseItems == true then

                Config.AddPlayerItem(source, Item.itemname, 1)

            end

        end

    end

end)

RegisterNetEvent("kofkof:addcoinsdb")

AddEventHandler('kofkof:addcoinsdb', function(source, total)

    MySQL.Async.execute("UPDATE MysteryCryptoMining SET coins = (coins + @coins) WHERE owner = @owner",

        {

            ['@owner'] = GetLicensse(source),

            ['@coins'] = total

        }

    )

end)



RegisterNetEvent("kofkof:sellcoins")

AddEventHandler('kofkof:sellcoins', function(source, amount)

    MySQL.Async.fetchAll("SELECT * FROM MysteryCryptoMining WHERE dono = @dono", {['@dono'] = GetLicensse(source)}, function(Machines)

        local coins = 0

        if Machines[1] ~= nil then

            coins = Machines[1].coins

        end

        if amount <= coins then

            Config.AddPlayerMoney(source, amount * Config.Price)

            MySQL.Async.execute("UPDATE MysteryCryptoMining SET coins = @coins WHERE owner = @owner",

                {

                    ['@owner'] = GetLicensse(source),

                    ['@coins'] = coins - amount

                }

            )

            TriggerClientEvent("kofkof:sendMessageCoin", source,  "~g~+"..(amount * Config.Price)..Config.Currency)

        else

            TriggerClientEvent("kofkof:sendMessageCoin", source, Config.msgs.donthavecoins ..coins)

        end

    end)

end)



RegisterNetEvent("kofkof:buycoins")

AddEventHandler('kofkof:buycoins', function(source, amount)

    MySQL.Async.fetchAll("SELECT * FROM MysteryCryptoMining WHERE owner = @owner", {['@owner'] = GetLicensse(source)}, function(Machines)

        local coins = 0

        if Machines[1] ~= nil then

            coins = Machines[1].coins

        end

        

        if Config.GetPlayerMoney(source) >= amount then

            Config.RemovePlayerMoney(source, amount)

            MySQL.Async.execute("UPDATE MysteryCryptoMining SET coins = @coins WHERE owner = @owner",

                {

                    ['@owner'] = GetLicensse(source),

                    ['@coins'] = coins + (amount / Config.Price)

                }

            )

            TriggerClientEvent("kofkof:sendMessageCoin", source,  "~g~+"..(amount / Config.Price).. Config.msgs.coinsname)

        else

            TriggerClientEvent("kofkof:sendMessageCoin", source, Config.msgs.donthavemoney ..amount..Config.Currency)

        end

    end)

end)



RegisterNetEvent("kofkof:mycoins")

AddEventHandler('kofkof:mycoins', function(source, amount)

    MySQL.Async.fetchAll("SELECT * FROM MysteryCryptoMining WHERE owner = @owner", {['@owner'] = GetLicensse(source)}, function(Machines)

        local coins = 0

        if Machines[1] ~= nil then

            coins = Machines[1].coins

        end

        

        TriggerClientEvent("kofkof:sendMessageCoin", source, Config.msgs.coinsamount ..coins.. " " ..Config.CoinName)

    end)

end)





function GetLicensse(source) 

    for k,v in pairs(GetPlayerIdentifiers(source))do

        if string.sub(v, 1, string.len("license:")) == "license:" then

            license = v

            return license

        end

    end

end