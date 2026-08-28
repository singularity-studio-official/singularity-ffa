local savedStates = {}
local savedInventories = {}

function FFA.SavePlayerState(src)
    local ped = GetPlayerPed(src)
    
    savedStates[src] = {
        coords = GetEntityCoords(ped),
        heading = GetEntityHeading(ped),
        health = GetEntityHealth(ped),
        armor = 0,
        bucket = GetPlayerRoutingBucket(src)
    }
    
    local player = exports.qbx_core:GetPlayer(src)
    if player then
        savedStates[src].armor = player.PlayerData.metadata['armor'] or 0
        savedStates[src].hunger = player.PlayerData.metadata['hunger'] or 100
        savedStates[src].thirst = player.PlayerData.metadata['thirst'] or 100
        
        -- Set to 100 so they don't starve during the match
        player.Functions.SetMetaData('hunger', 100)
        player.Functions.SetMetaData('thirst', 100)
    end
    
    -- Save and wipe inventory
    local invItems = exports.ox_inventory:GetInventoryItems(src)
    savedInventories[src] = {}
    if type(invItems) == 'table' then
        for _, item in pairs(invItems) do
            if item and item.name then
                table.insert(savedInventories[src], item)
            end
        end
    end
    
    exports.ox_inventory:ClearInventory(src)
end

function FFA.RestoreInventory(src)
    if savedInventories[src] then
        exports.ox_inventory:ClearInventory(src)
        for _, item in pairs(savedInventories[src]) do
            exports.ox_inventory:AddItem(src, item.name, item.count, item.metadata, item.slot)
        end
        savedInventories[src] = nil
    end
end

function FFA.RestoreHungerThirst(src)
    local state = savedStates[src]
    if not state then return end
    
    local player = exports.qbx_core:GetPlayer(src)
    if player then
        player.Functions.SetMetaData('hunger', state.hunger or 100)
        player.Functions.SetMetaData('thirst', state.thirst or 100)
    end
end

function FFA.GetSavedState(src)
    return savedStates[src]
end

function FFA.ClearSavedState(src)
    savedStates[src] = nil
    savedInventories[src] = nil
end
