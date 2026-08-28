local isDead = false

AddEventHandler('gameEventTriggered', function(event, data)
    if not FFA.inArena then return end
    
    if event == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        
        if victim == PlayerPedId() and IsEntityDead(victim) then
            if not isDead then
                isDead = true
                FFA.HandleDeath(attacker)
            end
        end
    end
end)

function FFA.HandleDeath(attacker)
    local attackerId = -1
    if attacker and IsEntityAPed(attacker) and IsPedAPlayer(attacker) then
        attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
    end
    
    TriggerServerEvent('singularity-ffa:server:PlayerDied', attackerId)
    
    FFA.stats.deaths = FFA.stats.deaths + 1
    FFA.stats.streak = 0
    if FFA.UpdateHUDStats then FFA.UpdateHUDStats() end
    
    lib.notify({
        title = 'Deathmatch',
        description = 'Respawning in ' .. (Config.RespawnTime / 1000) .. ' seconds...',
        type = 'error'
    })
    
    Wait(Config.RespawnTime)
    
    -- Revive natively first to guarantee independence
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityHealth(ped, Config.DefaultHealth or 200)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    
    -- Reset state bags manually
    if LocalPlayer then
        LocalPlayer.state:set('isDead', false, true)
        LocalPlayer.state:set('inLastStand', false, true)
    end
    
    -- Trigger common medical events just to clear their internal UI/loops
    TriggerEvent('hospital:client:Revive')
    TriggerEvent('qbx_medical:client:playerRevived')
    Wait(100)
    
    FFA.Spawn(FFA.currentArenaData)
    isDead = false
end

RegisterNetEvent('singularity-ffa:client:KillConfirmed', function(kills, streak)
    if not FFA.inArena then return end
    
    FFA.stats.kills = kills
    FFA.stats.streak = streak
    if FFA.UpdateHUDStats then FFA.UpdateHUDStats() end
    
    -- Restore health and armor on kill
    local ped = PlayerPedId()
    SetEntityHealth(ped, Config.DefaultHealth or 200)
    SetPedArmour(ped, Config.DefaultArmor or 100)
    ClearPedBloodDamage(ped)
    
    lib.notify({
        title = 'Kill Confirmed',
        description = 'Health and Armor restored!',
        type = 'success',
        duration = 2000
    })
end)
