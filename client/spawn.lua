local lastSpawnIndex = -1

function FFA.Spawn(arenaData)
    if not arenaData or not arenaData.spawnPoints then return end
    
    local numSpawns = #arenaData.spawnPoints
    if numSpawns == 0 then return end
    
    local spawnIndex = math.random(1, numSpawns)
    -- Try to avoid same spawn point if more than 1 exists
    if numSpawns > 1 and spawnIndex == lastSpawnIndex then
        spawnIndex = (spawnIndex % numSpawns) + 1
    end
    lastSpawnIndex = spawnIndex
    
    local spawnPoint = arenaData.spawnPoints[spawnIndex]
    
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(500)
    
    SetEntityCoords(ped, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, false)
    SetEntityHeading(ped, spawnPoint.w or 0.0)
    
    -- Set health and armor
    SetEntityHealth(ped, Config.DefaultHealth)
    SetPedArmour(ped, Config.DefaultArmor)
    
    TriggerServerEvent('singularity-ffa:server:RequestLoadout')
    
    Wait(500)
    
    if exports.ox_inventory then
        CreateThread(function()
            for i = 1, 10 do
                Wait(200)
                if GetSelectedPedWeapon(PlayerPedId()) == `WEAPON_UNARMED` then
                    exports.ox_inventory:useSlot(1)
                else
                    break
                end
            end
        end)
    end
    
    DoScreenFadeIn(500)
    
    -- Spawn Protection
    SetEntityInvincible(ped, true)
    SetEntityAlpha(ped, 150, false)
    
    lib.notify({
        title = 'Spawn Protection',
        description = 'You are protected for 3 seconds.',
        type = 'info',
        duration = 3000
    })
    
    CreateThread(function()
        Wait(3000)
        -- Ensure they are still in the arena before removing protection (in case they left)
        if FFA.inArena then
            SetEntityInvincible(ped, false)
            ResetEntityAlpha(ped)
            
            lib.notify({
                title = 'Protection Expired',
                description = 'You are now vulnerable!',
                type = 'warning'
            })
        end
    end)
end
