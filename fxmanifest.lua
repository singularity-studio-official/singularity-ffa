fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Singularity Studio'
description 'Free For All Arena System'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

client_scripts {
    'client/main.lua',
    'client/npc.lua',
    'client/menu.lua',
    'client/spawn.lua',
    'client/death.lua',
    'client/boundary.lua',
    'client/hud.lua'
}

server_scripts {
    'server/main.lua',
    'server/db.lua',
    'server/routing.lua',
    'server/player_state.lua',
    'server/loadout.lua'
}

dependencies {
    'oxmysql',
    'qbx_core',
    'ox_lib',
    'ox_target'
}

escrow_ignore {
    'config.lua',
    'ss_ffa.sql'
}