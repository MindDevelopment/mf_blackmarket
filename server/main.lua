local function itemIsValid(itemName)
    for i = 1, #Config.items do
        if Config.items[i].name == itemName then
            return true
        end
    end
    return false
end

local function getItemPrice(itemName)
    for i = 1, #Config.items do
        if Config.items[i].name == itemName then
            return Config.items[i].price
        end
    end
    return nil
end

lib.callback.register('mf_blackmarket:server:buyItems', function(source, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return { success = false } end

    local totalCost = 0
    local itemsToGive = {}

    for i = 1, #data do
        local entry = data[i]
        local price = getItemPrice(entry.name)
        if not price or not itemIsValid(entry.name) then
            return { success = false }
        end
        local amount = tonumber(entry.amount) or 1
        totalCost = totalCost + (price * amount)
        itemsToGive[#itemsToGive + 1] = { name = entry.name, amount = amount }
    end

    if totalCost <= 0 then
        return { success = false }
    end

    local cashBalance = player.PlayerData.money.cash
    local bankBalance = player.PlayerData.money.bank
    local paymentType

    if cashBalance >= totalCost then
        paymentType = 'cash'
    elseif bankBalance >= totalCost then
        paymentType = 'bank'
    else
        if cashBalance > 0 then
            return { success = false, reason = 'noBank' }
        else
            return { success = false, reason = 'noMoney' }
        end
    end

    if not player.Functions.RemoveMoney(paymentType, totalCost, 'black-market-purchase') then
        return { success = false }
    end

    for i = 1, #itemsToGive do
        exports.ox_inventory:AddItem(source, itemsToGive[i].name, itemsToGive[i].amount)
    end

    return { success = true }
end)
