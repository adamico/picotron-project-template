include('lib/pecs.lua')

include('lib/pecs.lua')

Timer = require('timer')
HoverTimer = Timer.new()
local play_music = false

Map = nil
Enemies = {}

local Play = SceneManager:addState('Play')

function Play:enteredState()
	systems = {}
	players = {}
	Map = fetch('assets/map/level1.map')[1].bmp
	memmap(Map, 0x100000)
	World = pecs()

	include('src/components.lua')
	include('src/factories/player.lua')
	include('src/factories/camera.lua')
	include('src/factories/spawner.lua')
	include('src/systems/index.lua')

	local player = Player:new()
	local playerEntity = player:makeEntity(1, 'Player1')

	local camera = Camera:new()
	camera:makeEntity(playerEntity)

	local spawner = SpawnerClass:new()
	spawner:makeEntity(15, 15, 64)
end

local lastTickTime = time()
function Play:update()
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

function Play:draw()
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

return Play