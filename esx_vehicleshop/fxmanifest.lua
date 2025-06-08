fx_version 'cerulean'
game 'gta5'

author 'Pitrs'
description 'Pitrs ESX Vehicle Shop'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'@ox_lib/init.lua',
	'locales/*.lua',
	'config.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@async/async.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/script.js'
}

dependencies {
	'es_extended',
	'oxmysql',
	'ox_lib'
}

lua54 'yes'
