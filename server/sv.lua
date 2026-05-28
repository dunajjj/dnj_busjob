local ESX = exports['es_extended']:getSharedObject()
local actk = {}

local function gntkn()
    return math.random(111111, 999999) .. "-" .. os.time()
end

lib.callback.register('dnj_bus:payd', function(source, account)
    local xpl = ESX.GetPlayerFromId(source)
    local price = dnj.depoprice
    if xpl.getAccount(account).money >= price then
        xpl.removeAccountMoney(account, price)
        local token = gntkn()
        actk[source] = token
        return token
    else
        return false
    end
end)

lib.callback.register('dnj_bus:collectpc', function(source, amount, token)
    local xpl = ESX.GetPlayerFromId(source)

    if not actk[source] or actk[source] ~= token then
        return false, 'invalid_token'
    end

    actk[source] = nil

    if not amount or amount <= 0 then
        return false, 'no_money'
    end

    if amount > 50000 then
        return false, 'too_much'
    end

    exports.ox_inventory:AddItem(source, 'money', amount)
    return true
end)
