local arenaWeapons = {}
local arenaAmmo = {}

RegisterNetEvent('singularity-ffa:server:RequestLoadout', function()
    local src = source
    if not FFA.players[src] then return end
    
    local arenaData = Config.Arenas[FFA.players[src].arenaIndex]
    if not arenaData or not arenaData.loadout then return end
    
    if FFA.RemoveLoadout then FFA.RemoveLoadout(src) end
    
    arenaWeapons[src] = {}
    arenaAmmo[src] = {}
    
    -- Give weapons
    local slot = 1
    for _, weapon in ipairs(arenaData.loadout) do
        -- Give to specific slot and fill the magazine via metadata
        if exports.ox_inventory:AddItem(src, weapon, 1, { ammo = 30 }, slot) then
            table.insert(arenaWeapons[src], weapon)
            slot = slot + 1
        end
    end
    
    -- Give ammo if configured
    if arenaData.ammo then
        for ammoName, amount in pairs(arenaData.ammo) do
            if exports.ox_inventory:AddItem(src, ammoName, amount) then
                table.insert(arenaAmmo[src], { name = ammoName, amount = amount })
            end
        end
    end
end)

function FFA.RemoveLoadout(src)
    if arenaWeapons[src] then
        for _, weapon in ipairs(arenaWeapons[src]) do
            exports.ox_inventory:RemoveItem(src, weapon, 1)
        end
        arenaWeapons[src] = nil
    end
    
    if arenaAmmo[src] then
        for _, ammoData in ipairs(arenaAmmo[src]) do
            -- Try to remove up to the amount we gave them, or just let them keep any extra they somehow scrounged?
            -- To prevent exploitation, we should try to remove what we gave them.
            -- Using GetItemCount could be safer, but RemoveItem handles it if they have less.
            exports.ox_inventory:RemoveItem(src, ammoData.name, ammoData.amount)
        end
        arenaAmmo[src] = nil
    end
end
