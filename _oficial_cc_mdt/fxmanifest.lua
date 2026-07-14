fx_version 'bodacious'
game 'gta5'

ui_page 'web/build/index.html' 
ui_page_preload 'yes' 

client_script '@PolyZone/client.lua'

files {
    'config/shared/*.lua',
    'config/client/*.lua',

    'framework/client/*.*',

	'stream/*.ytd',
	'web/build/*.*',
    'web/build/**/*.*', 
    'web/build/**/**/*.*', 
}

shared_script {
    'shared/utils/utils.lua',
	'shared/utils/Tools.lua',
	'shared/utils/Proxy.lua',
	'shared/utils/Tunnel.lua',

	'shared/main.lua',
    'shared/adapter_core.lua', 
    'shared/framework_registry.lua', 
    'shared/adapter_init.lua',
}

server_scripts {
	'server/main.lua',
	'server/updater.lua',
    
	'server/api/*.lua',
	'server/events/*.lua',
	'server/handlers/*.lua',
	'server/modules/*.lua'
}

client_scripts {
    'client/main.lua',

    'client/api/*.lua',
    'client/events/*.lua',
    'client/handlers/*.lua',
    'client/modules/*.lua',
    'client/web/*.lua'
}

dependencies {
    '/onesync',
    '/server:2843',
    'PolyZone'
}

transfer {
    'config/server/*.lua',
    'framework/server/*.lua'
}

ignore_server_scripts {
    'token.lua'
}

watch_file {
    '_server.lua', 
    '_client.lua', 
    'fxmanifest.lua', 
    'framework/client/adapter.lua', 
    'framework/server/adapter.lua', 
}
