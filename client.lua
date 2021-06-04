local SERVER_LOADED = false

RegisterNetEvent('kofkof:getCoinSTART')
AddEventHandler('kofkof:getCoinSTART', function()
    if SERVER_LOADED == false then
        SERVER_LOADED = true
    end
end)

Citizen.CreateThread(function()
    while SERVER_LOADED == false do
        TriggerServerEvent('kofkof:giveCoinSTART', GetSourceId())
        Citizen.Wait(10)
    end
end)


local Machines = nil
local MachinesSpawned = false
local PlayerName = nil
local ESX = nil

Citizen.CreateThread(function()
    if Config.StandAlone == false then
        Config.GetFrameworkClient()
    end
end)

Citizen.CreateThread(function()
    local PlayerSpawned = false

    while PlayerSpawned == false and SERVER_LOADED == false do
        Citizen.Wait(1000)
        if GetPlayerPed(-1) ~= nil then
            PlayerSpawned = true
        end
    end

    TriggerServerEvent("kofkof:GetMachines", GetSourceId())
    while MachinesSpawned == false do
        Citizen.Wait(10)
        if Machines ~= nil then
            for _, Machine in pairs(Machines) do
                Citizen.Wait(50)
                if Machine.machines ~= nil then
                    for __, PropInfo in pairs(Machine.machines) do
                        Citizen.Wait(50)
                        local Prop = CreateObject(GetHashKey("xm_base_cia_server_01"), 0, 0, 0, false, true, true)
                        PropInfo.propid = Prop
                        SetEntityCoords(Prop, PropInfo.x, PropInfo.y, PropInfo.z-1.0, 0, 0, 0, false)
                        SetEntityHeading(Prop, PropInfo.h)
                        FreezeEntityPosition(Prop, true)
                    end
                end
                local PropMonitor = CreateObject(GetHashKey("prop_monitor_w_large"), 0, 0, 0, false, true, true)
                Machine.monitor.propid[1] = PropMonitor
                SetEntityCoords(PropMonitor, Machine.monitor.x, Machine.monitor.y, Machine.monitor.z-0.32, 0, 0, 0, false)
                SetEntityHeading(PropMonitor, Machine.monitor.h)
                FreezeEntityPosition(PropMonitor, true)

                local PropMonitor = CreateObject(GetHashKey("prop_rub_table_01"), 0, 0, 0, false, true, true)
                Machine.monitor.propid[2] = PropMonitor
                SetEntityCoords(PropMonitor, Machine.monitor.x, Machine.monitor.y, Machine.monitor.z-0.7, 0, 0, 0, false)
                SetEntityHeading(PropMonitor, Machine.monitor.h)
                FreezeEntityPosition(PropMonitor, true)
            end
            MachinesSpawned = true
        end
    end

    while Config.Price == nil do
        Citizen.Wait(10)
    end

    while Config.Currency == nil do
        Citizen.Wait(10)
    end

    SendNUIMessage({
        open = "loadproducts",
        Products = Config.Products,
        CCoinPrice = Config.Price,
        Currency = Config.Currency,
    })

    while true do
        Citizen.Wait(5)
        local ped = GetPlayerPed(-1)
        for _, Machine in pairs(Machines) do
            for i, Server in pairs(Machine.machines) do
                Server.id = i
                local x,y,z = table.unpack(GetEntityCoords(ped))
                local dist = GetDistanceBetweenCoords(Server.x, Server.y, Server.z, x, y, z, true)
                if dist <= 2.0 then
                    local health = "~g~" .. Server.health .. "%~w~"
                    if Server.health <= 20 then
                        health = "~r~" .. Server.health .. "%~w~"
                    elseif Server.health <= 50 then
                        health = "~o~" .. Server.health .. "%~w~"
                    end
                    Drawing.draw3DText(Server.x, Server.y, Server.z,
                            "[~g~Serveur "..Server.id.."~w~ - "..health.."] ~n~ Appuyez sur [~g~G~w~] pour le ~r~supprimer~w~",
                            4, 0.10, 0.06, 255, 255, 255, 255)
                    if IsControlJustReleased(0, 47) and Machine.owner == PlayerName then
                        table.remove(Machine.machines, Server.id)

                        DeleteEntity(Server.propid)
                        TriggerServerEvent("kofkof:UpdateMachine", GetSourceId(), Machine)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local ped = GetPlayerPed(-1)
        if Machines ~= nil and SERVER_LOADED == true then
            for i, Machine in pairs(Machines) do
                local monitor = Machine.monitor
                local x,y,z = table.unpack(GetEntityCoords(ped))
                local dist = GetDistanceBetweenCoords(monitor.x, monitor.y, monitor.z, x, y, z, true)
                if dist <= 2.0 then
                    Drawing.draw3DText(monitor.x, monitor.y, monitor.z-0.85,
                            "[~g~Ordinateur~w~]~n~ Appuyez sur [~g~E~w~] pour ~g~ouvrir~w~ ~n~ Appuyez sur  [~g~H~w~] pour le ~r~supprimer~w~",
                            4, 0.07, 0.03, 255, 255, 255, 255)
                    if IsControlJustReleased(0, 38) and Machine.owner == PlayerName then
                        SetNuiFocus( true, true )
                        SendNUIMessage({
                            open = "open",
                            Machines = Machine.machines,
                            CoinName = Config.CoinName,
                        })
                    end

                    if IsControlJustReleased(0, 104) and Machine.owner == PlayerName then
                        for i, Server in pairs(Machine.machines) do
                            DeleteEntity(Server.propid)
                        end
                        DeleteEntity(monitor.propid[1])
                        DeleteEntity(monitor.propid[2])
                        table.remove(Machines, i)
                        TriggerServerEvent("kofkof:DeleteMachine", GetSourceId())
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UpdateTime)
        local ped = GetPlayerPed(-1)
        if Machines ~= nil and SERVER_LOADED == true then
            for _, Machine in pairs(Machines) do
                for i, Server in pairs(Machine.machines) do
                    if Server.status == true then
                        local MoreTemprature = tonumber(string.format("%.2f", (Config.TemperaturePerUpdate/Server.fans)))
                        if Server.temperature < 100 then
                            Server.temperature = tonumber(string.format("%.2f", (Server.temperature + MoreTemprature)))
                        end
                        Server.coins = tonumber(string.format("%.5f", (Server.kofcoins + (Config.CoinsPerUpdate * Server.GPUlevel))))

                        if Server.temperature > 0 and Server.temperature <= 50 then
                            Server.health = tonumber(string.format("%.2f", (Server.health - Config.HealthTakenPerUpdateHighHeath)))

                        elseif Server.temperature > 50 and Server.temperature <= 80 then
                            Server.health = tonumber(string.format("%.2f", (Server.health - Config.HealthTakenPerUpdateMidHeath)))

                        elseif Server.temperature > 80 and Server.temperature <= 110 then
                            Server.health = tonumber(string.format("%.2f", (Server.health - Config.HealthTakenPerUpdateLowHeath)))
                        end

                        if Server.health <= 0 then
                            DeleteEntity(Server.propid)
                            AddExplosion(Server.x, Server.y, Server.z, "EXPLOSION_GRENADE", 1.0, true, false, 1, true)

                            for i, ServerClose in pairs(Machine.machines) do
                                if Server.id ~= ServerClose.id then
                                    local distClose = GetDistanceBetweenCoords(Server.x, Server.y, Server.z, ServerClose.x, ServerClose.y, ServerClose.z, true)
                                    if distClose <= 2.0 then
                                        ServerClose.health = tonumber(string.format("%.2f", (ServerClose.health - Config.HealthTakenPerCloseExplosion)))
                                    end
                                end
                            end
                            table.remove(Machine.machines, Server.id)
                        end
                    elseif Server.status == false then
                        if Server.health <= 0 then
                            DeleteEntity(Server.propid)
                            AddExplosion(Server.x, Server.y, Server.z, "EXPLOSION_GRENADE", 1.0, true, false, 1, true)

                            for i, ServerClose in pairs(Machine.machines) do
                                if Server.id ~= ServerClose.id then
                                    local distClose = GetDistanceBetweenCoords(Server.x, Server.y, Server.z, ServerClose.x, ServerClose.y, ServerClose.z, true)

                                    if distClose <= 2.0 then
                                        ServerClose.health = tonumber(string.format("%.2f", (ServerClose.health - Config.HealthTakenPerCloseExplosion)))
                                    end
                                end
                            end
                            table.remove(Machine.machines, Server.id)
                        end
                        if Server.temperature > 0 then
                            local LessTemperature = tonumber(string.format("%.2f", (Config.TemperaturePerUpdate*Server.fans)))
                            Server.temperature = tonumber(string.format("%.2f", (Server.temperature - LessTemperature)))
                        end
                    end
                end
            end
        end
    end
end)


local CanUpdate = false
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus( false, false )
    SendNUIMessage({ open = "close", })
    CanUpdate = false
    cb('ok')
end)

RegisterNUICallback('startmachine', function(data, cb)
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName then
            for i, Server in pairs(Machine.machines) do
                if Server.id == data.machineid then
                    Server.status = true
                    break
                end
            end
            break
        end
    end
    cb('ok')
end)

RegisterNUICallback('stopmachine', function(data, cb)
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName then
            for i, Server in pairs(Machine.machines) do
                if Server.id == data.machineid then
                    Server.status = false
                    break
                end
            end
            break
        end
    end
    cb('ok')
end)


RegisterNUICallback('updatemachines', function(data, cb)
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName then
            SendNUIMessage({
                open = "update",
                Machines = Machine.machines,
            })
            CanUpdate = true
            break
        end
    end
    cb('ok')
end)

RegisterNUICallback('buyproducts', function(data, cb)
    local Cart = {}
    local Allprice = 0
    for _, CartProduct in pairs(data.products) do
        for _, Product in pairs(Config.Products) do
            if CartProduct == Product.label then
                Allprice = Allprice + Product.price
                table.insert(Cart, Product)
                break
            end
        end
    end

    TriggerServerEvent("kofkof:sendcartserver", GetSourceId(), Cart, Allprice)
    cb('ok')
end)

RegisterNUICallback('sellcoins', function(data, cb)
    local TotalCoins = data.allcoins
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName then
            for i, Server in pairs(Machine.machines) do
                Server.kofcoins = 0.00000
            end
            break
        end
    end
    TriggerServerEvent("kofkof:addcoinsdb", GetSourceId(), TotalCoins)
    cb('ok')
end)


RegisterCommand("sellcoins", function(source, args, rawCommand)
    if args[1] ~= nil then
        TriggerServerEvent("kofkof:sellcoins", GetSourceId(), tonumber(args[1]))
    else
        Notification(Config.msgs.invalidCoins)
    end
end)

RegisterCommand("buycoins", function(source, args, rawCommand)
    if args[1] ~= nil then
        TriggerServerEvent("kofkof:buycoins", GetSourceId(), tonumber(args[1]))
    else
        Notification(Config.msgs.invalidCoins)
    end
end)

RegisterCommand("coins", function(source, args, rawCommand)
    TriggerServerEvent("kofkof:mycoins", GetSourceId())
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UpdateTime)
        local ped = GetPlayerPed(-1)
        if Machines ~= nil and SERVER_LOADED == true then
            if CanUpdate == true then
                for _, Machine in pairs(Machines) do
                    if Machine.owner == PlayerName then
                        SendNUIMessage({
                            open = "update",
                            Machines = Machine.machines,
                            CCoinPrice = Config.Price,
                            Currency = Config.Currency,
                        })
                        break
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        local ped = GetPlayerPed(-1)
        if Machines ~= nil and SERVER_LOADED == true then
            for _, Machine in pairs(Machines) do
                if Machine.owner == PlayerName then
                    TriggerServerEvent("kofkof:UpdateMachine", GetSourceId(), Machine)
                    break
                end
            end
        end
    end
end)

RegisterNUICallback('balance', function(data, cb)
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName and SERVER_LOADED == true then
            SendNUIMessage({
                open = "balance",
                Machines = Machine.machines,
            })
            break
        end
    end
    cb('ok')
end)



RegisterCommand("placemonitor", function(source, args, rawCommand)
    if Config.UseItems == false and SERVER_LOADED == true then
        PlaceMonitor()
    end
end)

RegisterCommand("addserver", function(source, args, rawCommand)
    if Config.UseItems == false and SERVER_LOADED == true then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for j, Produto in pairs(Machine.boughtproducts) do
                    for i, Cprodutos in pairs(Config.Products) do
                        if Cprodutos.type == "server" and Cprodutos.itemname == Produto then
                            local added = AddServer()
                            if added == true then
                                table.remove(Machine.boughtproducts, j)
                            end
                            break
                        end
                    end
                end
                break
            end
        end
    end
end)


RegisterCommand("repairserver", function(source, args, rawCommand)
    if Config.UseItems == false and SERVER_LOADED == true then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for j, Produto in pairs(Machine.boughtproducts) do
                    for i, Cprodutos in pairs(Config.Products) do
                        if Cprodutos.type == "fix" and Cprodutos.itemname == Produto then
                            local added = RepairServer()
                            if added == true then
                                table.remove(Machine.boughtproducts, j)
                            end
                            break
                        end
                    end
                end
                break
            end
        end
    end
end)

RegisterCommand("addGPU", function(source, args, rawCommand)
    if Config.UseItems == false and SERVER_LOADED == true then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for j, Produto in pairs(Machine.boughtproducts) do
                    for i, Cprodutos in pairs(Config.Products) do
                        if Cprodutos.type == "gpu" and Cprodutos.itemname == Produto then
                            local added = AddGPU()
                            if added == true then
                                table.remove(Machine.boughtproducts, j)
                            end
                            break
                        end
                    end
                end
                break
            end
        end
    end
end)

RegisterCommand("addFan", function(source, args, rawCommand)
    if Config.UseItems == false and SERVER_LOADED == true then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for j, Produto in pairs(Machine.boughtproducts) do
                    for i, Cprodutos in pairs(Config.Products) do
                        if Cprodutos.type == "fan" and Cprodutos.itemname == Produto then
                            local added = AddFan()
                            if added == true then
                                table.remove(Machine.boughtproducts, j)
                            end
                            break
                        end
                    end
                end
                break
            end
        end
    end
end)


function PlaceMonitor()
    local ped= GetPlayerPed(-1)
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
    local heading = GetEntityHeading(ped)
    local machineInfo = GetMachine()

    if machineInfo == false then

        machineInfo = {
            owner=PlayerName,
            machines={
            },
            monitor={
                x= coords.x,
                y= coords.y,
                z= coords.z,
                h= heading,
                propid={0}
            },
            boughtproducts={
            }

        }

        local PropMonitor = CreateObject(GetHashKey("prop_monitor_w_large"), 0, 0, 0, true, true, true)
        machineInfo.monitor.propid[1] = PropMonitor
        SetEntityCoords(PropMonitor, machineInfo.monitor.x, machineInfo.monitor.y, machineInfo.monitor.z-0.32, 0, 0, 0, false)
        SetEntityHeading(PropMonitor, machineInfo.monitor.h)
        FreezeEntityPosition(PropMonitor, true)

        local PropMonitor = CreateObject(GetHashKey("prop_rub_table_01"), 0, 0, 0, true, true, true)
        machineInfo.monitor.propid[2] = PropMonitor
        SetEntityCoords(PropMonitor, machineInfo.monitor.x, machineInfo.monitor.y, machineInfo.monitor.z-0.7, 0, 0, 0, false)
        SetEntityHeading(PropMonitor, machineInfo.monitor.h)
        FreezeEntityPosition(PropMonitor, true)

        table.insert(Machines, machineInfo)
        TriggerServerEvent("kofkof:CreateMachine", GetSourceId(), machineInfo)
        Notification(Config.msgs.monitoradded)
    else
        Notification(Config.msgs.maxmonitors)
    end
end

function AddServer()
    local ped= GetPlayerPed(-1)
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
    local heading = GetEntityHeading(ped)
    local machineInfo = GetMachine()
    local check = false

    if machineInfo ~= false then
        local pedcoords = GetEntityCoords(ped)
        local machinedist = GetDistanceBetweenCoords(machineInfo.monitor.x, machineInfo.monitor.y, machineInfo.monitor.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
        if machinedist <= 10.0 then
            local serversamount = GetTableSize(machineInfo.machines)
            if serversamount < Config.MaxServers then
                local serverinfo = {
                    id= serversamount + 1,
                    x= coords.x,
                    y= coords.y,
                    z= coords.z,
                    h= heading,
                    propid=0,
                    temperature= 0,
                    kofcoins= 0.00000,
                    status= false,
                    fans= 1,
                    rams= 1,
                    GPUlevel= 1,
                    health= 100
                }

                local ModelHash = GetModelHash(GetHashKey("xm_base_cia_server_01"))
                local Prop = CreateObject(ModelHash, 0, 0, 0, true, true, true)
                serverinfo.propid = Prop
                SetEntityCoords(Prop, serverinfo.x, serverinfo.y, serverinfo.z-1.05, 0, 0, 0, false)
                SetEntityHeading(Prop, serverinfo.h)
                FreezeEntityPosition(serverinfo.propid, true)

                table.insert(machineInfo.machines, serverinfo)
                TriggerServerEvent("kofkof:UpdateMachine", GetSourceId(), machineInfo)
                Notification(Config.msgs.serveradded)
                check = true
            else
                Notification(Config.msgs.maxservers)
            end
        end
    else

    end
    return check
end


function RepairServer()
    local closestServer, closestdistance = ClosestServer()
    local check = false

    if closestServer ~= nil and closestdistance <= 3 then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for i, Server in pairs(Machine.machines) do
                    if Server.id == closestServer then
                        Notification(Config.msgs.repairing)
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                        Citizen.Wait(10000)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        Notification(Config.msgs.repaired)
                        Server.health = 100
                        check = true
                        break
                    end
                end
                break
            end
        end
    end

    return check
end

function AddGPU()
    local closestServer, closestdistance = ClosestServer()
    local check = false

    if closestServer ~= nil and closestdistance <= 3 then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for i, Server in pairs(Machine.machines) do
                    if Server.id == closestServer and Server.GPUlevel < Config.MaxGPU then
                        Notification(Config.msgs.placinggpu)
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                        Citizen.Wait(10000)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        Notification(Config.msgs.placedgpu)
                        Server.GPUlevel = Server.GPUlevel + 1
                        check = true
                        break
                    end
                end
                break
            end
        end
    end

    return check
end

function AddFan()
    local closestServer, closestdistance = ClosestServer()
    local check = false

    if closestServer ~= nil and closestdistance <= 3 then
        for _, Machine in pairs(Machines) do
            if Machine.owner == PlayerName then
                for i, Server in pairs(Machine.machines) do
                    if Server.id == closestServer and Server.fans < Config.MaxFans then
                        Notification(Config.msgs.placingfan)
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                        Citizen.Wait(10000)
                        ClearPedTasksImmediately(GetPlayerPed(-1))
                        Notification(Config.msgs.placedfan)
                        Server.fans = Server.fans + 1
                        check = true
                        break
                    end
                end
                break
            end
        end
    end

    return check
end

function ClosestServer()
    local closestserver = nil
    local closestdistance = 9999
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName then
            for i, Server in pairs(Machine.machines) do
                local dist = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Server.x, Server.y, Server.z, true)
                if dist < closestdistance then
                    closestdistance = dist
                    closestserver = Server.id
                end
            end
            break
        end
    end

    return closestserver, closestdistance
end

RegisterNetEvent('kofkof:GetMachinesCallBack')
AddEventHandler('kofkof:GetMachinesCallBack', function(machines, playername)
    Machines = machines
    PlayerName = playername
end)


RegisterNetEvent('kofkof:SpawnPlaceMonitor')
AddEventHandler('kofkof:SpawnPlaceMonitor', function()
    PlaceMonitor()
end)

RegisterNetEvent('kofkof:RepairServer')
AddEventHandler('kofkof:RepairServer', function()
    RepairServer()
end)


RegisterNetEvent('kofkof:SpawnServer')
AddEventHandler('kofkof:SpawnServer', function()
    AddServer()
end)

RegisterNetEvent('kofkof:UseGPU')
AddEventHandler('kofkof:UseGPU', function()
    AddGPU()
end)


RegisterNetEvent('kofkof:UseFan')
AddEventHandler('kofkof:UseFan', function()
    AddFan()
end)

RegisterNetEvent('kofkof:AddProductToMachine')
AddEventHandler('kofkof:AddProductToMachine', function(itemname)
    for _, Machine in pairs(Machines) do
        if Machine.owner == PlayerName and SERVER_LOADED == true then
            table.insert(Machine.boughtproducts, itemname)
            break
        end
    end
end)

RegisterNetEvent('kofkof:sendMessageCoin')
AddEventHandler('kofkof:sendMessageCoin', function(msg)
    Notification(msg)
end)

function GetSourceId()
    local playersource = GetPlayerServerId(PlayerId())
    return playersource
end

function GetTableSize(table)
    local count = 0
    for _, row in pairs(table) do
        count = count + 1
    end
    return count
end

function GetMachine()
    local machineInfo = false
    for _, Machine in pairs(Machines) do
        Citizen.Wait(50)
        if Machine.owner == PlayerName then
            machineInfo = Machine
        end
    end

    return machineInfo

end

function GetModelHash(model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    return model
end


Drawing = setmetatable({}, Drawing)
Drawing.__index = Drawing

function Drawing.draw3DText(x,y,z,textInput,fontId,scaleX,scaleY,r, g, b, a)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*14
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(8)
    SetTextProportional(1)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+1, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function Notification(msg)
    SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(msg)
        DrawNotification(false, true)
end