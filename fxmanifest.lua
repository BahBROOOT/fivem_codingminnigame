-- Resource Metadata
fx_version 'cerulean'
game 'gta5'

author 'BahBROOOT'
description 'A coding minnigame for FiveM made by BahBROOOT'
version '1.0.0'

--[[
    NOTE: Keep for custom env in load func to work if you really **cant use lua54**
    uncomment the logic beneath the "5.1 compatibility" comment in the runSnippetClientside function
    and comment out the , env parameter in the load function within the runSnippetClientside function
]]
lua54 'yes'

shared_scripts {
    'shared/*.lua',
}

client_scripts {
    'client/func/*.lua',
    'tasks/*.lua',
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

files {
    'nui/*.html',
}

ui_page 'nui/test.html'