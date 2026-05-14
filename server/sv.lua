local ESX = exports['es_extended']:getSharedObject()
local actk = {}

local function gntkn()
    return math.random(111111, 999999) .. "-" .. os.time()
end

lib.callback.register('dnj_bus:payd', function(source, account)
    local xpl = ESX.GetPlayerFromId(source)
    local price = dnj.depoprice

    if xpl.getAccount(account).money >= price then -- lwk nwm ci ma ox lib check na account money
        xpl.removeAccountMoney(account, price)
        
        local token = gntkn()
        actk[source] = token
        return token
    else
        return false
    end
end)

RegisterNetEvent('dnj_bus:collectpc', function(amount, token)
    local src = source
    local xpl = ESX.GetPlayerFromId(src)
    
    if not actk[src] or actk[src] ~= token then
   --     DropPlayer(src, 'secure - busjob.')
        return
    end

    actk[src] = nil

    if amount and amount > 0 then
        if amount > 50000 then 
            return
        end
        
        exports_ox_inventory:AddItem(src, 'money', amount)
        TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = 'Dostal si výplatu: $'..amount})
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Nemáš žiadne peniaze na vyplatenie!'})
    end
end)
