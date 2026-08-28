function FFA.OpenMenu()
    lib.callback('singularity-ffa:server:GetArenaCounts', false, function(counts)
        lib.callback('singularity-ffa:server:GetLeaderboard', false, function(leaderboard)
            local arenasData = {}
            
            for i, arena in ipairs(Config.Arenas) do
                local count = counts[i] or 0
                local maxPlayers = arena.maxPlayers or 15
                
                table.insert(arenasData, {
                    index = i,
                    name = arena.name,
                    description = arena.description or '',
                    count = count,
                    maxPlayers = maxPlayers
                })
            end
            
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openMenu',
                arenas = arenasData,
                leaderboard = leaderboard
            })
        end)
    end)
end

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
    if cb then cb('ok') end
end)

RegisterNUICallback('joinArena', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
    
    if data and data.index then
        TriggerServerEvent('singularity-ffa:server:JoinArena', data.index)
    end
    if cb then cb('ok') end
end)
