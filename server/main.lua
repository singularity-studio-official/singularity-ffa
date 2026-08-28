FFA = FFA or {}
FFA.players = FFA.players or {}

lib.callback.register('singularity-ffa:server:GetArenaCounts', function(source)
    local counts = {}
    for i=1, #Config.Arenas do counts[i] = 0 end
    
    for src, data in pairs(FFA.players) do
        if counts[data.arenaIndex] then
            counts[data.arenaIndex] = counts[data.arenaIndex] + 1
        end
    end
    
    return counts
end)

RegisterNetEvent('singularity-ffa:server:JoinArena', function(arenaIndex)
    local src = source
    local arenaData = Config.Arenas[arenaIndex]
    if not arenaData then return end
    
    if FFA.players[src] then return end
    
    local currentCount = 0
    for _, data in pairs(FFA.players) do
        if data.arenaIndex == arenaIndex then
            currentCount = currentCount + 1
        end
    end
    
    local maxPlayers = arenaData.maxPlayers or 15
    if currentCount >= maxPlayers then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Deathmatch',
            description = 'This arena is currently full!',
            type = 'error'
        })
        return
    end
    
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local citizenid = player.PlayerData.citizenid

    FFA.DB.GetPlayerStats(citizenid, function(stats)
        FFA.players[src] = {
            arenaIndex = arenaIndex,
            citizenid = citizenid,
            kills = stats.kills,
            deaths = stats.deaths,
            streak = 0
        }
        
        if FFA.SavePlayerState then FFA.SavePlayerState(src) end
        if FFA.SetPlayerRouting then FFA.SetPlayerRouting(src, arenaData.bucket) end
        
        TriggerClientEvent('singularity-ffa:client:EnterArena', src, arenaIndex, arenaData, stats)
    end)
end)

RegisterCommand(Config.LeaveCommand, function(source, args, raw)
    local src = source
    if not FFA.players[src] then return end
    
    local state = nil
    if FFA.GetSavedState then state = FFA.GetSavedState(src) end
    
    if FFA.RemoveLoadout then FFA.RemoveLoadout(src) end
    if FFA.ResetPlayerRouting then FFA.ResetPlayerRouting(src) end
    if FFA.RestoreInventory then FFA.RestoreInventory(src) end
    if FFA.RestoreHungerThirst then FFA.RestoreHungerThirst(src) end
    if FFA.ClearSavedState then FFA.ClearSavedState(src) end
    
    FFA.players[src] = nil
    TriggerClientEvent('singularity-ffa:client:LeaveArena', src, state)
end, false)

RegisterNetEvent('singularity-ffa:server:PlayerDied', function(attackerId)
    local src = source
    if not FFA.players[src] then return end
    
    FFA.players[src].deaths = FFA.players[src].deaths + 1
    FFA.players[src].streak = 0
    FFA.DB.AddDeath(FFA.players[src].citizenid)
    
    local function getPlayerNameExt(id)
        local p = exports.qbx_core:GetPlayer(id)
        if p and p.PlayerData and p.PlayerData.charinfo then
            return p.PlayerData.charinfo.firstname .. ' ' .. p.PlayerData.charinfo.lastname
        end
        return GetPlayerName(id) or "Unknown"
    end

    if attackerId and attackerId > 0 and FFA.players[attackerId] then
        if FFA.players[attackerId].arenaIndex == FFA.players[src].arenaIndex then
            FFA.players[attackerId].kills = FFA.players[attackerId].kills + 1
            FFA.players[attackerId].streak = FFA.players[attackerId].streak + 1
            FFA.DB.AddKill(FFA.players[attackerId].citizenid)
            TriggerClientEvent('singularity-ffa:client:KillConfirmed', attackerId, FFA.players[attackerId].kills, FFA.players[attackerId].streak)
            
            local victimName = getPlayerNameExt(src)
            local attackerName = getPlayerNameExt(attackerId)
            
            -- Notify Attacker
            TriggerClientEvent('ox_lib:notify', attackerId, {
                title = 'Kill Confirmed',
                description = 'You killed ' .. victimName,
                type = 'success'
            })
            
            -- Notify Victim
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Wasted',
                description = 'You were killed by ' .. attackerName,
                type = 'error'
            })
        end
    else
        -- Notify Victim of suicide or environmental death
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Wasted',
            description = 'You died',
            type = 'error'
        })
    end
    
    if FFA.RemoveLoadout then FFA.RemoveLoadout(src) end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if FFA.players[src] then
        if FFA.RestoreInventory then FFA.RestoreInventory(src) end
        if FFA.RestoreHungerThirst then FFA.RestoreHungerThirst(src) end
        if FFA.ClearSavedState then FFA.ClearSavedState(src) end
        FFA.players[src] = nil
    end
end)

lib.callback.register('singularity-ffa:server:GetLeaderboard', function(source)
    local p = promise.new()
    FFA.DB.GetLeaderboard(function(result)
        local formatted = {}
        if result then
            for i, row in ipairs(result) do
                local name = "Unknown"
                if row.charinfo then
                    local charinfo = json.decode(row.charinfo)
                    if charinfo and charinfo.firstname and charinfo.lastname then
                        name = charinfo.firstname .. " " .. charinfo.lastname
                    end
                end
                
                local calcDeaths = math.max(1, row.deaths)
                local kd = row.kills / calcDeaths
                
                table.insert(formatted, {
                    rank = i,
                    name = name,
                    kills = row.kills,
                    deaths = row.deaths,
                    kd = kd
                })
            end
        end
        p:resolve(formatted)
    end)
    return Citizen.Await(p)
end)

