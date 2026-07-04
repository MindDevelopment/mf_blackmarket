fx_version 'adamant'
game 'gta5'

author 'MindFramework'
description 'Black Market - Qbox / ox_inventory / ox_target'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/app.css',
    'web/images/*.png',
}
