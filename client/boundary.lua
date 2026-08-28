local arenaZone = nil

function FFA.SetupBoundary(arenaData)
    if not arenaData.zone then return end
    
    arenaZone = lib.zones.poly({
        points = arenaData.zone.points,
        thickness = arenaData.zone.thickness,
        debug = true, -- This makes the zone walls visible to the player in-game
        inside = function()
        end,
        onEnter = function()
        end,
        onExit = function()
            if FFA.inArena then
                lib.notify({
                    title = 'Out of Bounds',
                    description = 'You cannot leave the Deathmatch zone.',
                    type = 'error'
                })
                
                local spawnPoints = arenaData.spawnPoints
                if spawnPoints and #spawnPoints > 0 then
                    local spawnIndex = math.random(1, #spawnPoints)
                    local spawnPoint = spawnPoints[spawnIndex]
                    
                    local ped = PlayerPedId()
                    DoScreenFadeOut(200)
                    Wait(200)
                    SetEntityCoords(ped, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, false)
                    if spawnPoint.w then
                        SetEntityHeading(ped, spawnPoint.w)
                    end
                    Wait(200)
                    DoScreenFadeIn(200)
                end
            end
        end
    })
end

function FFA.RemoveBoundary()
    if arenaZone then
        arenaZone:remove()
        arenaZone = nil
    end
end
