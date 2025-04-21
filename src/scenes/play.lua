local pgui = require("pgui")
tiny 			 = require('tiny')
Timer      = require('timer')
class   	 = require('middleclass')
local bump = require('bump')

local drawDebug = require('drawDebug')

local Play = SceneManager:addState('Play')

Map = nil

Enemies  = {}
Players  = {}
Spawners = {}
Cameras  = {}
BumpWorld = bump.newWorld(TileSizeX)

local play_music = false

local Player  = require('player')
local Camera  = require('camera')
local Spawner = require('spawner')

local function addPlayers()
	local player
	player = Player:new('myself', vec(9,9))
	add(Players, player)
	world:add(player)
end

local function addSpawners()
	local positions = {vec(15,15), vec(30,14), vec(20,20)}
	for position in all(positions) do
		local spawner_sprite = 64
		spawner = Spawner:new(position, spawner_sprite)
		world:add(spawner)
	end
end

local function addCams()
	for player in all(Players) do
		local cam = Camera:new(player)
		add(Cameras, cam)
		world:add(cam)
	end
end

function Play:enteredState()
	Map = fetch('assets/map/level1.map')[1].bmp
	memmap(Map, 0x100000)

	world = world or tiny.world(
		require('handleGameOver'),
		require('handleInput'),
		require('capture'),
		require('moveActors')(BumpWorld),
		require('shooting'),
		require('updateActorState'),
		require('moveBullets')(BumpWorld),
		require('drawSprites'),
		require('killBullets'),
		require('spawnEnemies'),
		require('executeAI'),
		require('drawUI')
	)

	addPlayers()
	addCams()
	addSpawners()
end

local drawFilter 	 = tiny.requireAll('isDrawSystem')
local updateFilter = tiny.rejectAny('isDrawSystem')

local lastTickTime = time()
function Play:update()
	if #Players > 0 then
		AddDebug("p1pos", pod(Players[1].position))
		AddDebug("p1st",  pod(Players[1].state.machine.current))
	-- AddDebug("capturing", pod(Players[1].isCapturing()))
	-- AddDebug("protected", pod(Players[1].isProtected()))
	end
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

	for cam in all(Cameras) do
		cam:update()
	end

	map(0, 0, 0, 0, 48, 48, 0, TileSizeX, TileSizeY)

	if world then world:update(dt, drawFilter) end

	camera()
	drawDebug()
	pgui:draw()
end

return Play