local game = {}

Map = nil
Enemies = {}

local play_music = false

game.initLevel = function()
	Map = fetch("map/level1.map")[1].bmp
	memmap(Map, 0x100000)
end

game.init = function()
	systems = {}
	players = {}
	game.initLevel()
	World = pecs()
	include("components.lua")
	include("factories/player.lua")
	include("factories/camera.lua")
	include("factories/spawner.lua")

	local player = Player:new()
	local playerEntity = player:makeEntity(1, "Player1")

	local camera = Camera:new()
	camera:makeEntity(playerEntity)

	local spawner = SpawnerClass:new()
	spawner:makeEntity(15, 15, 64)

	include("systems/index.lua")
end

game.update = function()
	if play_music then music(0, 1000) play_music = false end
	World.update()
	pgui:refresh()
	systems.handleInput()
	systems.updateActorState()
	systems.capture()
	systems.moveActors()
	systems.shoot()
	systems.moveBullets()
	systems.killBullets()
	systems.spawnEnemies()
	systems.animateActors()
end

game.draw = function()
	cls(1)
	systems.move_camera()
	pal(0, false)
	map(0, 0, 0, 0, 48, 48, 0, TileSizeX, TileSizeY)
	systems.drawSpawners()
	systems.drawBullets()
	systems.drawActors()

	camera()
	systems.drawDebug()
	pgui:draw()
end

return game