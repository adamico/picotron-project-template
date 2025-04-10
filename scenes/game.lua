local pecs = require('pecs')

local game = {}

Map = nil

local play_music = false

PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

game.initLevel = function()
	Map = fetch("map/level1.map")[1].bmp
	memmap(Map, 0x100000)
end

game.init = function()
	canCapture = function(player_number, x, y)
		local tile_number = mget(x, y)
		return tile_number ~= PlayerTiles[player_number+1]
	end
	sounds = {
		start_engine = 48,
		stop_engine = 49,
		start_capturing = 50,
		captured = 51,
	}
	systems = {}
	game.initLevel()
	World = pecs()
	include("components/index.lua")
	include("entities/index.lua")
	include("systems/index.lua")
end

-- main functions for Scenes

game.update = function()
	if play_music then music(0, 1000) play_music = false end
	World.update()
	pgui:refresh()
	systems.handleInput()
	systems.capture()
	systems.move()
	systems.updatePlayerState()
	systems.animatePlayer()
	-- systems.soundizePlayer()
end

game.draw = function()
	cls(1)
	systems.move_camera()
	pal(0, false)
	map(0, 0, 0, 0, 48, 48, 0, tile_size_x, tile_size_y)
	systems.drawPlayer()
	camera()
	systems.drawDebug()
	pgui:draw()
end

return game