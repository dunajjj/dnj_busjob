local ESX = exports['es_extended']:getSharedObject()
local crbus = nil
local activeroute = nil
local busblip = nil
local crstop = 0
local passengers = {}
local pendingcheck = 0
local buscam = nil
local pedmain = nil
local jtkn = nil
local avstops = {}

-- jebem localessssssssssssssssssssssssssssssssssssssssssssssssssssssss

CreateThread(function()
    --[[local blip = AddBlipForCoord(dnj.npc.coords.x, dnj.npc.coords.y, dnj.npc.coords.z)
    SetBlipSprite(blip, dnj.npc.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, dnj.npc.blip.scale)
    SetBlipColour(blip, dnj.npc.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<FONT FACE="Lexend">' .. dnj.npc.blip.label .. '</FONT>')
    EndTextCommandSetBlipName(blip)--]]

    local model = lib.requestModel(dnj.npc.model)
    pedmain = CreatePed(4, model, dnj.npc.coords.x, dnj.npc.coords.y, dnj.npc.coords.z - 1.0, dnj.npc.coords.w, false, true)
    FreezeEntityPosition(pedmain, true)
    SetEntityInvincible(pedmain, true)
    SetBlockingOfNonTemporaryEvents(pedmain, true)
    TaskStartScenarioInPlace(pedmain, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    exports.ox_target:addLocalEntity(pedmain, {
        {
            name = 'bus_job_start',
            icon = 'fa-solid fa-bus',
            label = 'Začít práci řidiče',
            canInteract = function() 
                return not crbus and pendingcheck == 0 
            end,
            onSelect = function()
                initbusjob()
            end
        },
        {
            name = 'bus_job_collect',
            icon = 'fa-solid fa-money-bill',
            label = 'Vyplatit šek',
            canInteract = function() 
                return not crbus and pendingcheck > 0 
            end,
            onSelect = function()
                local ok, reason = lib.callback.await('dnj_bus:collectpc', false, pendingcheck, jtkn)
                if ok then
                    lib.notify({ type = 'success', description = 'Dostal jsi výplatu: $' .. pendingcheck })
                    pendingcheck = 0
                    jtkn = nil
                elseif reason == 'no_money' then
                    lib.notify({ type = 'error', description = 'Nemáš nic na vyplacení' })
                else
                    lib.notify({ type = 'error', description = 'Něco se pokazilo.' })
                end
            end
        }
    })
end)

function initbusjob()
    local alert = lib.alertDialog({
        header = 'Řidič autobusu',
        content = 'Chceš začít směnu? Budeš muset zaplatit zálohu $'..dnj.depoprice..'.',
        labels = {
            confirm = "Jo chci!",
            cancel = "Ne, někdy jindy..."
        },
        centered = true,
        cancel = true
    })

    if alert == 'cancel' then return end

    local input = lib.inputDialog('Platba zálohy', {
        {
            type = 'select',
            label = 'Způsob platby',
            options = {
                { value = 'money', label = 'Hotovost' },
                { value = 'bank', label = 'Banka' }
            },
            required = true
        }
    })

    if not input then return end
    local paymenttype = input[1]

    local token = lib.callback.await('dnj_bus:payd', false, paymenttype)
    if not token then
        return lib.notify({type = 'error', description = 'Nemáš dostatek peněz na zálohu!'})
    end
    
    jtkn = token
    
    avstops = {}
    for i = 1, #dnj.stops do
        table.insert(avstops, i)
    end
    
    spawnbus()
end

function spawnbus()
    local spawnpoint = nil

    for _, point in ipairs(dnj.spawns) do
        if not IsPositionOccupied(point.coords.x, point.coords.y, point.coords.z, 5.0, false, true, true, false, false, 0, false) then
            spawnpoint = point
            break
        end
    end

    if not spawnpoint then
        lib.notify({type = 'error', description = 'Všechny výjezdy jsou obsazené, zkus to za chvíli!'})
        return
    end

    lib.requestModel(dnj.bmodel)
    crbus = CreateVehicle(GetHashKey(dnj.bmodel), spawnpoint.coords.x, spawnpoint.coords.y, spawnpoint.coords.z, spawnpoint.heading, true, false)
    SetVehicleNumberPlateText(crbus, "BUS"..math.random(100,999))
    SetVehicleDoorsLocked(crbus, 1)
    
    lib.notify({type = 'success', description = 'Autobus přistaven! Najdi ho a nastup.'})
    
    crstop = 0
    pendingcheck = 0
    
    busstatus()
    
    Wait(2000)
    nextstop()
end

function busstatus()
    CreateThread(function()
        while crbus and DoesEntityExist(crbus) do
            local pped = PlayerPedId()
            local isinbus = GetVehiclePedIsIn(pped, false) == crbus
            
            if not isinbus then
                local buscoords = GetEntityCoords(crbus)
                local dist = #(GetEntityCoords(pped) - buscoords)
                
                if dist < 100.0 then
                    DrawMarker(29, buscoords.x, buscoords.y, buscoords.z + 3.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 200, true, true, 2, nil, nil, false)
                end
                
                if not DoesBlipExist(busblip) then
                    busblip = AddBlipForEntity(crbus)
                    SetBlipSprite(busblip, 513)
                    SetBlipColour(busblip, 22)
                    SetBlipScale(busblip, 0.7)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString('<FONT FACE="Lexend">Autobus</FONT>')
                    EndTextCommandSetBlipName(busblip)
                end
            else
                if DoesBlipExist(busblip) then
                    RemoveBlip(busblip)
                    busblip = nil
                end
            end
            
            Wait(5)
        end
        
        if DoesBlipExist(busblip) then RemoveBlip(busblip) end
        busblip = nil
    end)
end

function nextstop()
    if not crbus or not DoesEntityExist(crbus) then return end
    
    if #avstops == 0 then
        lib.notify({title = 'Konec trasy', description = 'Projel jsi všechny zastávky. Vrať se do depa.', type = 'info'})
        return endjob(true)
    end

    crstop = crstop + 1

    local rindex = math.random(1, #avstops)
    local actualstop = avstops[rindex]
    table.remove(avstops, rindex)

    local stopdata = dnj.stops[actualstop]
    local stopcoords = stopdata.coords
    
    if activeroute then RemoveBlip(activeroute) end
    activeroute = AddBlipForCoord(stopcoords.x, stopcoords.y, stopcoords.z)
    SetBlipSprite(activeroute, 164)
    SetBlipColour(activeroute, 13)
    SetBlipRoute(activeroute, true)
    SetBlipRouteColour(activeroute, 13)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<FONT FACE="Lexend">Zastávka</FONT>')
    EndTextCommandSetBlipName(activeroute)

    lib.notify({title = 'Nová zastávka', description = 'Jeď na označenou zastávku a naber lidi.', type = 'info'})

    while true do
        Wait(500)
        local pped = PlayerPedId()
        
        if not DoesEntityExist(crbus) then 
            endjob(false)
            return 
        end

        local dist = #(GetEntityCoords(crbus) - stopcoords)
        
        if dist < 10.0 then
            if GetVehiclePedIsIn(pped, false) ~= crbus then
                lib.showTextUI('Musíš nastoupit do autobusu!', {position = "top-center", icon = "bus", style = {borderRadius = 0, backgroundColor = '#ff0000', color = 'white'}})
            else
                local speed = GetEntitySpeed(crbus) * 3.6
                if speed < 2.0 then
                    DoScreenFadeOut(500)
                    Wait(600) 
                    
                    dostoplogic(stopdata)
                    break
                else
                    lib.showTextUI('[E] Zastavit')
                    if IsControlJustPressed(0, 38) then
                        DoScreenFadeOut(500)
                        Wait(600)
                        
                        dostoplogic(stopdata)
                        break
                    end
                end
            end
        else
            lib.hideTextUI()
        end
    end
end

function tooglecam(state)
    if state then
        if not DoesCamExist(buscam) then
            buscam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        end
        
        
        local offsetcrds = GetOffsetFromEntityInWorldCoords(crbus, 8.0, 2.0, 1.5)
        
        SetCamCoord(buscam, offsetcrds.x, offsetcrds.y, offsetcrds.z)
        
        PointCamAtEntity(buscam, crbus, 0.0, 0.0, 0.0, true)
        
        SetCamActive(buscam, true)
        RenderScriptCams(true, true, 0, true, true)
    else
        RenderScriptCams(false, true, 0, true, true)
        SetTimeout(1000, function()
            if DoesCamExist(buscam) then DestroyCam(buscam, false) end
            buscam = nil
        end)
    end
end

function dostoplogic(stopdata)
    lib.hideTextUI()
    
    local crheading = GetEntityHeading(crbus)
    local tcoords = stopdata.coords
    
    SetVehicleForwardSpeed(crbus, 0.0)
    SetVehicleEngineOn(crbus, false, true, true)
    
    SetEntityCoords(crbus, tcoords.x, tcoords.y, tcoords.z, false, false, false, true)
    SetEntityHeading(crbus, stopdata.heading or crheading)
    SetVehicleOnGroundProperly(crbus)
    FreezeEntityPosition(crbus, true)
    
    tooglecam(true)
    
    SetVehicleDoorOpen(crbus, 0, false, false)
    SetVehicleDoorOpen(crbus, 1, false, false)
    SetVehicleDoorOpen(crbus, 2, false, false)
    SetVehicleDoorOpen(crbus, 3, false, false)

    Wait(500)
    DoScreenFadeIn(500)
    Wait(500)

    if crstop > 1 and #passengers > 0 then
        lib.notify({description = 'Cestující vystupují...'})
        local exitcount = math.random(1, #passengers)
        for i = 1, exitcount do
            local ped = passengers[1] 
            table.remove(passengers, 1)
            
            TaskLeaveVehicle(ped, crbus, 0)
            
            SetTimeout(1500, function()
                local spawncoords = stopdata.pedsspawn or GetOffsetFromEntityInWorldCoords(crbus, 5.0, -5.0, 0.0)
                TaskGoStraightToCoord(ped, spawncoords.x, spawncoords.y, spawncoords.z, 1.0, -1, 0.0, 0.0)
                
                SetTimeout(5000, function() 
                    if DoesEntityExist(ped) then DeleteEntity(ped) end 
                end)
            end)
            Wait(1200)
        end
    end

    lib.notify({description = 'Cestující nastupují...'})
    local entercount = math.random(1, 4)
    local avseats = GetVehicleMaxNumberOfPassengers(crbus) - #passengers - 1

    if entercount > avseats then entercount = avseats end

    for i = 1, entercount do
        local model = dnj.pds[math.random(#dnj.pds)]
        lib.requestModel(model)
        
        local spawncoords = stopdata.pedsspawn
        
        if not spawncoords then
            local fallbackDist = 20.0
            local angle = math.random(45, 160)
            local radians = math.rad(GetEntityHeading(crbus) - angle)
            local sx = stopdata.coords.x + (math.cos(radians) * fallbackDist)
            local sy = stopdata.coords.y + (math.sin(radians) * fallbackDist)
            spawncoords = vector3(sx, sy, stopdata.coords.z)
        end
        
        local ped = CreatePed(4, GetHashKey(model), spawncoords.x, spawncoords.y, spawncoords.z, 0.0, true, false)
        
        TaskEnterVehicle(ped, crbus, -1, i, 1.5, 1, 0)
        table.insert(passengers, ped)
        
        Wait(math.random(1500, 3000)) 
    end
    
    local mwait = entercount * 8000 + 4000
    local timer = 0
    
    while timer < mwait do
        local allin = true
        for _, p in pairs(passengers) do
            if not IsPedInVehicle(p, crbus, false) and not IsEntityDead(p) then
                allin = false
                break
            end
        end
        if allin then break end
        Wait(1000)
        timer = timer + 1000
    end

    DoScreenFadeOut(500)
    Wait(600)

    SetVehicleDoorShut(crbus, 0, false)
    SetVehicleDoorShut(crbus, 1, false)
    SetVehicleDoorShut(crbus, 2, false)
    SetVehicleDoorShut(crbus, 3, false)
    SetVehicleEngineOn(crbus, true, true, false)
    
    tooglecam(false)
    FreezeEntityPosition(crbus, false)

    DoScreenFadeIn(500)

    local reward = 0
    if crstop > 1 then
        reward = math.random(dnj.rewards.min, dnj.rewards.max)
        pendingcheck = pendingcheck + reward
    end

    local alert = 'Zastávka dokončena.'
    if reward > 0 then 
        alert = 'Vydělal jsi na šek: $'..reward..'. Celkem máš: $'..pendingcheck..'. Pokračujeme?' 
    else
        alert = 'První zastávka je zahřívací. Pokračujeme?'
    end

    local choice = lib.alertDialog({
        header = 'Status Zastávky ('..crstop..'/'..dnj.mxstops..')',
        content = alert,
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Pokračovat',
            cancel = 'Ukončit směnu'
        }
    })

    if choice == 'confirm' then
        nextstop()
    else
        endjob(false)
    end
end

function endjob(forced)
    if activeroute then RemoveBlip(activeroute) end
    
    lib.notify({title = 'Konec směny', description = 'Vrať autobus do depa pro výplatu!', type = 'info'})
    
    activeroute = AddBlipForCoord(dnj.depo.x, dnj.depo.y, dnj.depo.z)
    SetBlipSprite(activeroute, 461)
    SetBlipColour(activeroute, 23)
    SetBlipRoute(activeroute, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<FONT FACE="Lexend">Depo</FONT>')
    EndTextCommandSetBlipName(activeroute)

    while true do
        Wait(1000)
        local dist = #(GetEntityCoords(PlayerPedId()) - dnj.depo)
        if dist < 10.0 then
            if GetVehiclePedIsIn(PlayerPedId(), false) == crbus then
                local speed = GetEntitySpeed(crbus)
                if speed < 1.0 then
                    DeleteVehicle(crbus)
                    crbus = nil
                    
                    for _, ped in pairs(passengers) do
                        if DoesEntityExist(ped) then DeleteEntity(ped) end
                    end
                    passengers = {}

                    if activeroute then RemoveBlip(activeroute) end
                    if busblip and DoesBlipExist(busblip) then RemoveBlip(busblip) end
                    
                    pendingcheck = pendingcheck + 100
                    
                    lib.alertDialog({
                        header = 'Práce ukončena',
                        content = 'Autobus vrácen. Vydělal jsi celkem $'..pendingcheck..'. Jdi si pro výplatu k šéfovi!',
                        labels = {
                            confirm = "Jasně"
                        },
                        centered = true
                    })
                    break
                else
                    lib.notify({type='warning', description='Zastav vozidlo!'})
                end
            end
        end
    end
end

AddEventHandler('onResourceStop', function(rsname)
    if (GetCurrentResourceName() ~= rsname) then return end
    
    if crbus and DoesEntityExist(crbus) then DeleteEntity(crbus) end
    if pedmain and DoesEntityExist(pedmain) then DeleteEntity(pedmain) end
    
    for _, ped in pairs(passengers) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    
    if activeroute then RemoveBlip(activeroute) end
    if busblip then RemoveBlip(busblip) end
    
    if buscam and DoesCamExist(buscam) then 
        DestroyCam(buscam, false) 
        RenderScriptCams(false, false, 0, 1, 0)
    end
end)
