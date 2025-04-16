local pgui = require("pgui")
ecs 			 = require('tiny')
Timer      = require('timer')
class   	 = require('middleclass')

HoverTimer = Timer.new()

local Play = SceneManager:addState('Play')

Map = nil
Enemies = {}
players = {}

local play_music = false

local Player  = require('player')
local Camera  = require('camera')
local Spawner = require('spawner')

--systems

local player, cam, spawner

function Play:enteredState()
	Map = fetch('assets/map/level1.map')[1].bmp
	memmap(Map, 0x100000)

	player = Player:new('myself', vec(9,9))
	add(players, player)

	cam = Camera:new(player)

	local spawner_position = vec(15,15)
	local spawner_sprite = 64
	spawner = Spawner:new(spawner_position, spawner_sprite)

	world = ecs.world(
		require('handleInput'),
		require('capture'),
		require('moveActors'),
		require('shooting'),
		require('updateActorState'),
		require('moveBullets'),
		require('drawSprites'),
		require('killBullets'),
		require('spawnEnemies'),
		require('drawUI')
	)

	world:add(player)
	world:add(cam)
	world:add(spawner)
end

local drawFilter = ecs.requireAll('isDrawSystem')
local updateFilter = ecs.rejectAny('isDrawSystem')

local lastTickTime = time()
function Play:update()
	local tickTime = time()
	local dt = tickTime - lastTickTime
	if world then world:update(dt, updateFilter) end
	if play_music then music(0, 1000) play_music = false end
	pgui:refresh()

	-- systems.animateActors()

	Timer.update(dt)
	HoverTimer:update(dt)

	lastTickTime = tickTime
end

local drawDebug = require('drawDebug')

function Play:draw()
	local tickTime = time()
	local dt = tickTime - lastTickTime
	cls(1)
	pal(0, false)

	cam:update()

	map(0, 0, 0, 0, 48, 48, 0, TileSizeX, TileSizeY)

	if world then world:update(dt, drawFilter) end
	-- systems.drawSpawners()
	-- systems.drawActors()
	-- player:draw()

	camera()
	-- drawDebug:update(dt)
	-- systems.drawUI()
	drawDebug(player, spawner)
	pgui:draw()
end

return Play