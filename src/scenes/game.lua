include("lib/pecs.lua")
Timer = require("timer")
local log = require("log")
local game = {}

HoverTimer = Timer.new()

Map = nil
Enemies = {}

local play_music = false

game.initLevel = function()
	Map = fetch("assets/map/level1.map")[1].bmp
	memmap(Map, 0x100000)
end

game.init = function()
	systems = {}
	players = {}
	game.initLevel()
	World = pecs()
	include("src/components.lua")
	include("src/factories/player.lua")
	include("src/factories/camera.lua")
	include("src/factories/spawner.lua")

	local player = Player:new()
	local playerEntity = player:makeEntity(1, "Player1")

	local camera = Camera:new()
	camera:makeEntity(playerEntity)

	local spawner = SpawnerClass:new()
	spawner:makeEntity(15, 15, 64)

	include("src/systems/index.lua")
end

local lastTickTime = time()
game.update = function()
	local tickTime = time()
	local dt = tickTime - lastTickTime
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
	Timer.update(dt)
	HoverTimer:update(dt)
	lastTickTime = tickTime
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
	systems.drawUI()
	pgui:draw()
end

return game