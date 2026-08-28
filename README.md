# Singularity FFA (Free-for-All Deathmatch)

**Author:** ZephyrDox For Singularity Studio  
**Version:** 1.1  
**Framework:** Qbox / QBCore  

A premium, fully-featured, and highly optimized Free-for-All Deathmatch script. Built for seamless integration and maximum performance, it allows server owners to create multiple custom arena zones with dedicated loadouts and persistent stat tracking.

## Key Features

* **Advanced PolyZone Boundaries:** Draw completely custom polygon-shaped borders for your arenas with unlimited points.
* **Intelligent State Memory:** Players' exact locations, health, armor, and inventory are perfectly memorized before entering and flawlessly restored when they leave.
* **Medical Script Override:** Aggressively bypasses default medical systems (`qbx_medical`, `qb-ambulancejob`, etc.) while inside the arena. Players won't bleed out or limp at low HP during a gunfight.
* **Flawless Instancing:** Uses routing buckets to perfectly isolate Deathmatch players from the rest of the server.
* **Modern UI:** Sleek, glassmorphism-inspired HTML/CSS interface for Arena Selection and a live combat HUD.
* **Persistent Stat Tracking:** Automatically tracks and saves Kills, Deaths, and K/D ratios to the database.
* **Custom Loadouts:** Configure specific weapons and ammo caps per individual map.
* **NPC Integration:** Spawns a dedicated interactive ped to join the fight, complete with a configurable blip.

## Dependencies

Ensure you have the following resources installed and started before `singularity-ffa`:
* [`ox_lib`](https://github.com/overextended/ox_lib)
* [`ox_target`](https://github.com/overextended/ox_target)
* [`oxmysql`](https://github.com/overextended/oxmysql)
* [`qbx_core`](https://github.com/Qbox-project/qbx_core) (or QBCore equivalent)

## Installation

1. Drag and drop the `singularity-ffa` folder into your resources directory (e.g., `[singularity-studio]`).
2. Run the included `ss_ffa.sql` file in your SQL database (HeidiSQL, phpMyAdmin, etc.) to create the stats table.
   * *Note: The script also contains an auto-initialize query in `server/db.lua` as a fallback.*
3. Add `ensure singularity-ffa` to your `server.cfg`.

## Usage & Commands

* **Joining:** Interact with the configured NPC using `ox_target` to open the Arena Selection menu.
* **Leaving:** Players can type `/quitdm` (this command can be customized in `config.lua`) to instantly exit the arena and restore their previous state.

## Configuration (`config.lua`)

The `config.lua` file gives you total control over the script. You can edit:
* The Leave Command
* Default Health & Armor values
* Respawn Times
* NPC Model, Coordinates, and Blip settings
* Infinite Arenas (Name, Max Players, Routing Bucket, Weapons, Ammo, Polygon boundaries, and Spawn Points)

## Editing Arena Boundaries
Boundaries use `lib.zones.poly`. You can add as many `vec3(x, y, z)` coordinates as you like into the `points` array for an arena to draw incredibly complex, custom-shaped borders. If a player steps outside the border, they will be safely teleported back to a random spawn point.
