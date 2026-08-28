function FFA.ToggleHUD(state)
    if state then
        SendNUIMessage({
            action = 'showHUD'
        })
        FFA.UpdateHUDStats()
    else
        SendNUIMessage({
            action = 'hideHUD'
        })
    end
end

function FFA.UpdateHUDStats()
    if not FFA.inArena then return end
    
    local kd = 0.0
    if FFA.stats.deaths > 0 then
        kd = FFA.stats.kills / FFA.stats.deaths
    else
        kd = FFA.stats.kills
    end
    
    SendNUIMessage({
        action = 'updateHUD',
        stats = {
            arenaName = FFA.currentArenaData.name or 'ARENA',
            kills = FFA.stats.kills,
            deaths = FFA.stats.deaths,
            kd = kd,
            streak = FFA.stats.streak,
            leaveCommand = Config.LeaveCommand or 'quitdm'
        }
    })
end
