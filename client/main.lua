FFA = {
    inArena = false,
    currentArenaIndex = nil,
    currentArenaData = nil,
    stats = {
        kills = 0,
        deaths = 0,
        streak = 0
    }
}

RegisterNetEvent('singularity-ffa:client:EnterArena', function(arenaIndex, arenaData, stats)
    FFA.inArena = true
    FFA.currentArenaIndex = arenaIndex
    FFA.currentArenaData = arenaData
    FFA.stats = stats or { kills = 0, deaths = 0, streak = 0 }
    if not FFA.stats.streak then FFA.stats.streak = 0 end
    
    -- Setup zone
    if FFA.SetupBoundary then FFA.SetupBoundary(arenaData) end
    -- Initial spawn
    if FFA.Spawn then FFA.Spawn(arenaData) end
    -- Show HUD
    if FFA.ToggleHUD then FFA.ToggleHUD(true) end
    
    -- Override Medical Scripts Loop
    CreateThread(function()
        while FFA.inArena do
            Wait(1000)
            -- Reset QBCore/Qbox/Wasabi injuries and bleed states constantly
            TriggerEvent('hospital:client:ResetBones')
            TriggerEvent('hospital:client:HealInjuries', 'full')
            TriggerEvent('wasabi_ambulance:heal', true, true)
            
            -- Ensure no weird state bags get stuck if they take damage
            if LocalPlayer and LocalPlayer.state.isBleeding then
                LocalPlayer.state:set('isBleeding', false, true)
            end
        end
    end)
    
    lib.notify({
        title = 'Deathmatch',
        description = 'Joined ' .. arenaData.name,
        type = 'success'
    })
end)

RegisterNetEvent('singularity-ffa:client:LeaveArena', function(state)
    FFA.inArena = false
    FFA.currentArenaIndex = nil
    FFA.currentArenaData = nil
    
    -- Destroy zone
    if FFA.RemoveBoundary then FFA.RemoveBoundary() end
    -- Hide HUD
    if FFA.ToggleHUD then FFA.ToggleHUD(false) end
    
    -- Reset spawn protection
    SetEntityInvincible(PlayerPedId(), false)
    ResetEntityAlpha(PlayerPedId())
    
    if state then
        local ped = PlayerPedId()
        DoScreenFadeOut(500)
        Wait(500)
        SetEntityCoords(ped, state.coords.x, state.coords.y, state.coords.z, false, false, false, false)
        SetEntityHeading(ped, state.heading)
        SetEntityHealth(ped, state.health)
        SetPedArmour(ped, state.armor)
        Wait(500)
        DoScreenFadeIn(500)
    end
    
    lib.notify({
        title = 'Deathmatch',
        description = 'You have left the Deathmatch.',
        type = 'inform'
    })
end)

exports('isInFFA', function()
    return FFA.inArena
end)
