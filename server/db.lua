FFA = FFA or {}
FFA.DB = {}

-- Initialize the database table on resource start
CreateThread(function()
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `ss_ffa_stats` (
            `citizenid` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
            `kills` int(11) NOT NULL DEFAULT 0,
            `deaths` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    -- Ensure existing table collation is converted seamlessly
    exports.oxmysql:execute([[
        ALTER TABLE `ss_ffa_stats` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ]])
    print('^2[SINGULARITY-FFA]^7 Database table initialized.')
end)

--- Get global stats for a player
function FFA.DB.GetPlayerStats(citizenid, cb)
    exports.oxmysql:execute('SELECT kills, deaths FROM ss_ffa_stats WHERE citizenid = ?', {citizenid}, function(result)
        if result and result[1] then
            cb(result[1])
        else
            -- Insert new player row if they don't exist
            exports.oxmysql:execute('INSERT INTO ss_ffa_stats (citizenid, kills, deaths) VALUES (?, 0, 0)', {citizenid})
            cb({ kills = 0, deaths = 0 })
        end
    end)
end

--- Add a kill to a player's global stats
function FFA.DB.AddKill(citizenid)
    exports.oxmysql:execute('UPDATE ss_ffa_stats SET kills = kills + 1 WHERE citizenid = ?', {citizenid})
end

--- Add a death to a player's global stats
function FFA.DB.AddDeath(citizenid)
    exports.oxmysql:execute('UPDATE ss_ffa_stats SET deaths = deaths + 1 WHERE citizenid = ?', {citizenid})
end

--- Get Top 10 Leaderboard
function FFA.DB.GetLeaderboard(cb)
    exports.oxmysql:execute([[
        SELECT 
            f.citizenid, 
            f.kills, 
            f.deaths, 
            p.charinfo 
        FROM ss_ffa_stats f 
        LEFT JOIN players p ON f.citizenid COLLATE utf8mb4_unicode_ci = p.citizenid COLLATE utf8mb4_unicode_ci
        ORDER BY f.kills DESC 
        LIMIT 10
    ]], {}, function(result)
        cb(result)
    end)
end

