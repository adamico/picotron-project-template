local pecs = require("pecs")

local game = {}

Map = nil

local play_music = false

game.initLevel = function()
	Map = fetch("map/level1.map")[1].bmp
	memmap(Map, 0x100000)
end

game.init = function()
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
	systems.shoot()
	systems.moveBullets()
	systems.killBullets()
	systems.updatePlayerState()
	systems.animatePlayer()
	-- systems.soundizePlayer()
end

game.draw = function()
	cls(1)
	systems.move_camera()
	pal(0, false)
	map(0, 0, 0, 0, 48, 48, 0, TileSizeX, TileSizeY)
	systems.drawBullets()
	systems.drawPlayer()


	camera()
	systems.drawDebug()
	pgui:draw()
end

return game