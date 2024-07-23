fx_version 'cerulean'
game 'gta5'

author 'Votre Nom'
description 'Parcours de chat ESX Legacy'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'mysql-async'
}