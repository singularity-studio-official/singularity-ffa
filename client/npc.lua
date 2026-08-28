local npcEntity = nil

CreateThread(function()
    local cfg = Config.NPC
    local model = lib.requestModel(cfg.model, 10000)
    if not model then return end

    npcEntity = CreatePed(0, model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, false)
    FreezeEntityPosition(npcEntity, true)
    SetEntityInvincible(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)

    if cfg.blip and cfg.blip.enabled then
        local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(blip, cfg.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, cfg.blip.scale)
        SetBlipColour(blip, cfg.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(cfg.blip.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addLocalEntity(npcEntity, {
        {
            name = 'ss_ffa_join',
            icon = 'fa-solid fa-crosshairs',
            label = 'Join Deathmatch',
            onSelect = function()
                if FFA and FFA.OpenMenu then
                    FFA.OpenMenu()
                end
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if npcEntity then
            DeleteEntity(npcEntity)
        end
    end
end)
