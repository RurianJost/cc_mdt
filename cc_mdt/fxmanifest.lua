fx_version 'bodacious'

game 'gta5'

ui_page 'web/build/index.html'

ui_page_preload 'yes'

files {
    'config/shared/*.lua',
    'config/client/*.lua',
    'framework/client/*.*',
    'stream/*.ytd',
    'web/build/*.*',
    'web/build/**/*.*',
    'web/build/**/**/*.*'
}

dependencies {
    '/onesync',
    '/server:2843',
    'PolyZone'
}

watch_file {
    '_server.lua',
    '_client.lua',
    'fxmanifest.lua',
    'framework/client/adapter.lua',
    'framework/server/adapter.lua',
    'web/build/index.html',
    'web/build/assets/index.js',
    'web/build/assets/index.css',
    'web/build/assets/bg.png',
    'web/build/assets/defaultAvatar.png',
    'web/build/assets/layers.png',
    'web/build/assets/layers-2x.png',
    'web/build/assets/marker-icon.png',
    'web/build/assets/policeLogo.png',
    'web/build/assets/tiles/**/*.png'
}

client_scripts {
    '@PolyZone/client.lua'
}

server_scripts {
    'token.lua'
}

server_script '_server.lua'
client_script '_client.lua'