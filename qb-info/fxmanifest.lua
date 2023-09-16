fx_version 'cerulean'
game 'gta5'

description 'qb-info'
version '1.0.0'

ui_page 'html/ui.html'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'html/*'
}

exports {
    'ShowInfo',
    'HideInfo',
}

lua54 'yes'