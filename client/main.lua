local ped, isOpen = nil, false

local function openMarket()
    if isOpen then return end
    isOpen = true

    local formatted = {}
    for i = 1, #Config.items do
        formatted[#formatted + 1] = {
            name = Config.items[i].name,
            label = Config.items[i].label,
            price = Config.items[i].price,
            category = Config.items[i].category,
        }
    end

    SendNUIMessage({ action = 'open', items = formatted })
    SetNuiFocus(true, true)
end

local function closeMarket()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('buyItems', function(data, cb)
    local result = lib.callback.await('mf_blackmarket:server:buyItems', false, data)
    if result.success then
        exports.qbx_core:Notify(Config.notify.purchased, 'success')
        closeMarket()
    elseif result.reason == 'noMoney' then
        exports.qbx_core:Notify(Config.notify.noMoney, 'error')
    elseif result.reason == 'noBank' then
        exports.qbx_core:Notify(Config.notify.noBank, 'error')
    end
    cb(result)
end)

RegisterNUICallback('close', function(_, cb)
    closeMarket()
    cb('ok')
end)

CreateThread(function()
    local coords = Config.ped.coords

    RequestModel(Config.ped.model)
    while not HasModelLoaded(Config.ped.model) do
        Wait(0)
    end

    ped = CreatePed(1, Config.ped.model, coords.x, coords.y, coords.z - 0.98, coords.w, false, false)
    SetPedRandomComponentVariation(ped, true)
    SetPedRandomProps(ped)
    TaskStartScenarioInPlace(ped, Config.ped.scenario, 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            icon = Config.ped.targetIcon,
            label = Config.ped.targetLabel,
            distance = Config.ped.drawDistance,
            onSelect = openMarket,
        },
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeMarket()
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
        ped = nil
    end
end)
