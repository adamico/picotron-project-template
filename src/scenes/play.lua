local pgui = require("pgui")
tiny 			 = require('tiny')
Timer      = require('timer')
class   	 = require('middleclass')
local bump = require('bump')

local drawDebug = require('drawDebug')

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

local CheckTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

function Play:enteredState()
	Map = fetch('assets/map/level1.map')[1].bmp
	memmap(Map, 0x100000)

	bumpWorld = bump.newWorld(TileSizeX)
	player = Player:new('myself', vec(9,9))
	add(players, player)

	cam = Camera:new(player)

	local spawner_position = vec(15,15)
	local spawner_sprite = 64
	spawner = Spawner:new(spawner_position, spawner_sprite)

	world = tiny.world(
		require('handleInput'),
		require('capture'),
		require('moveActors')(bumpWorld),
		require('shooting'),
		require('updateActorState'),
		require('moveBullets'),
		require('drawSprites'),
		require('killBullets'),
		require('spawnEnemies'),
		require('executeAI'),
		require('drawUI')
	)

	world:add(player)
	world:add(cam)
	world:add(spawner)
end

local drawFilter 	 = tiny.requireAll('isDrawSystem')
local updateFilter = tiny.rejectAny('isDrawSystem')

local lastTickTime = time()
function Play:update()
	AddDebug("player", pod(players[1].position))
	AddDebug("capturing", pod(players[1].isCapturing()))
	AddDebug("protected", pod(players[1].isProtected()))
	

	local tickTime = time()
	local dt = tickTime - lastTickTime
	if world then world:update(dt, updateFilter) end
	if play_music then music(0, 1000) play_music = false end
	pgui:refresh()

	Timer.update(dt)

	lastTickTime = tickTime
end

function Play:draw()
	local tickTime = time()
	local dt = tickTime - lastTickTime
	cls(1)
	pal(0, false)

	cam:update()

	map(0, 0, 0, 0, 48, 48, 0, TileSizeX, TileSizeY)

	if world then world:update(dt, drawFilter) end

	camera()
	drawDebug(player, spawner)
	pgui:draw()
end

return Play