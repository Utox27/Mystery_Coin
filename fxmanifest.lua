fx_version 'adamant'
games { 'rdr3', 'gta5' }

mod 'Mystery-kofcoin'
version '1.1'

ui_page "ui/ui.html"

files {
	"ui/ui.html",
	"ui/*.css",
	"ui/*.js",
	"ui/img/*.png",
	"ui/*.png",
}

client_scripts {
	"config.lua",
	'client.lua',
}

server_scripts {
  	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
  	'server.lua',
  	--'credentials.lua',
}

