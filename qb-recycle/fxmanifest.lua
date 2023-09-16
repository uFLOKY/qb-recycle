fx_version 'cerulean'
game 'gta5'

description 'qb-recycle'
version '1.0.0'

shared_scripts {
	'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua',
    'client/minirec.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/minirec.lua',
}

server_exports {
}

lua54 'yes'
