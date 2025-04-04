--[[pod_format="raw",created="2024-09-08 09:50:07",modified="2025-04-04 09:25:46",revision=6]]
--[[
	main.lua - program entry points
	(c) 2025 Andrew Vasilyev. All rights reserved.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <https://www.gnu.org/licenses/>.
]]

Title = "GeoArena"
Version = "0.1"
Author = "kc00l"
Date = date("2020-%Y")

include("globals.lua")
include("require.lua")
include("configuration.lua")
include("lib/pecs.lua")

add_module_path("lib/")

local log = require("log")

tile_size_x = 18
tile_size_y = 18
screen_left = 0
screen_right = 480

screen_top = 0
screen_bottom = 270
screen_c_x = screen_right/2
screen_c_y = screen_bottom/2
grid_columns = screen_right/tile_size_x
grid_rows = screen_bottom/tile_size_y

local directions = {
	x = {-1, 1, 0, 0, 1, 1, -1, -1},
	y = { 0, 0,-1, 1,-1, 1,  1, -1}
}

World = pecs()
State = 0
NextState = 0

Map = nil

-- components
local Position = World.component({ x = 0, y = 0 })
local Box = World.component()
local Player = World.component(
	{ number = 0,
		moving = false
	}
)

local Follower = World.component({ following = nil, within = nil })
local Speed = World.component()
local Sprite = World.component()
local Animation = World.component()
local Rectangle = World.component({ border_color = 0 })

function initGame()
	Map = fetch("map/level1.map")[1].bmp
	local playerWidth, playerHeight = 15, 15
	local playerEntity = World.entity(
		{ name = "Player" },
		Animation({
			offset_x = 0,
			offset_y = 0,
			start_offset_x = 0,
			start_offset_y = 0,
			offset_t = 0,
			flip = false,
			sprites = {1, 2, 3, 4}
		}),
		Box({ x = 0, y = 0, w = playerWidth, h = playerHeight} ),
		Player({
			moving = false,
			capturing = false,
			capture_time = 0
		}),
		Position({ x = 1, y = 1 }),
		Speed({ x = tile_size_x, y = tile_size_y }),
		Sprite({ value = 1 })
	)

	local cameraLeft = -2.5 * tile_size_x
	local cameraTop = -2 * tile_size_y
	local cameraWidth = 7.5 * tile_size_x
	local cameraHeight = 19 * tile_size_y
	World.entity(
		{ name = "Camera" },
		Follower({ following = playerEntity }),
		Position({ x = 0, y = 0 }),
		Box({ x = cameraLeft, y = cameraTop, w = cameraWidth, h = cameraHeight }),
		Rectangle({ border_color = 12 })
	)
end

local handleInput = function ()
	local offset_x, offset_y = 0, 0
	local flip = false
	local dx, dy = 0, 0
	for i=0,3 do
		if btn(i) then
			dx = directions.x[i+1]
			dy = directions.y[i+1]
			offset_x = tile_size_x * -dx
			offset_y = tile_size_y * -dy
			flip = dx < 0
		end
	end

	return dx, dy, offset_x, offset_y, flip
end

local checkTileFlag = function (x, y, flag)
	local tile = Map:get(x, y)
	return fget(tile, flag)
end

local canMoveTo = function (x, y)
	return not checkTileFlag(x, y, 0)
end

-- #systems

local move = World.system({ Position, Player }, function (entity)
	local position = entity[Position]
	local animation = entity[Animation]

	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local new_x, new_y = position.x, position.y
	local dx, dy

	if animation.offset_t == 0 then
		new_offset_x, new_offset_y = 0, 0
		dx, dy, new_offset_x, new_offset_y, animation.flip = handleInput()
		new_x = position.x + dx
		new_y = position.y + dy
	end

	if (new_x ~= position.x or new_y ~= position.y) and
	canMoveTo(new_x, new_y) then
		position.x = mid(0, new_x, 31)
		position.y = mid(0, new_y, 31)
		animation.start_offset_x = new_offset_x
		animation.start_offset_y = new_offset_y
		animation.offset_t = 1
	end

	animation.offset_t = max(animation.offset_t - 0.125, 0)
	animation.offset_x = animation.start_offset_x * animation.offset_t
	animation.offset_y = animation.start_offset_y * animation.offset_t
end)

local animate = World.system({Sprite, Animation}, function (entity)
	local animation = entity[Animation]
	local sprite = entity[Sprite]
	local sprites = animation.sprites
	local sprite_index = flr((t()*6)%4+1)
	sprite.value = sprites[sprite_index]
end)

local capture = World.system({Player, Position}, function (entity)
	if not btn(4) then return end
	local captured_tiles = {}
	local position = entity[Position]
	local player = entity[Player]

	add(captured_tiles, { x = position.x, y = position.y, number = 66 })

	if #captured_tiles > 0 then
		player.capturing = true
		player.capture_time = player.capture_time + 1 --TODO: parameterize capture_time delta
	end

	if player.capture_time >= 100 then
		for tile in all(captured_tiles) do
			Map:set(tile.x, tile.y, tile.number)
		end
		player.capture_time = 0
		player.capturing = false
	end
end)

local drawCapture = World.system({Player, Position}, function (entity)
	local player = entity[Player]
	if not player.capturing then return end

end)

local drawSprites = World.system({Position, Sprite}, function (entity)
	local sprite = entity[Sprite].value
	local animation = entity[Animation]

	palt(30, true)
	palt(0, false)
	spr(sprite,
			entity[Position].x * tile_size_x + animation.offset_x + 2,
			entity[Position].y * tile_size_y + animation.offset_y + 2)
end)

local move_camera = World.system({ Follower, Position }, function (entity)
	local player = entity[Follower].following
	local cam_x = mid(
		-2.5 * tile_size_x,
		(player[Position].x - 12.5) * tile_size_x + player[Animation].offset_x,
		7.5 * tile_size_x
	)
	local cam_y = mid(
		-2 * tile_size_y,
		(player[Position].y - 7) * tile_size_y + player[Animation].offset_y,
		19 * tile_size_y
	)

	entity[Position].x = cam_x
	entity[Position].y = cam_y

	camera(cam_x, cam_y)
end)

function _updateGame()
	World.update()
	animate()
	move()
	capture()
end

function _drawGame()
	cls(32)
	move_camera()
	map(Map, 0, 0, 0, 0, 32, 32, 0, tile_size_x, tile_size_y)
	drawCapture()
	drawSprites()
	camera()
	print("cpu:"..flr(stat(1)*100), 10, 0, 7)
end

function _updateGameOver()
	if btnp(4) then State = 0 end
end

function _drawGameOver()
	cls(14)
	camera()
	local message = "Game over!"
	local message_length = #message*4
  print(message, screen_c_x - message_length/2, screen_bottom/6 + 1, 7)
  print(message, screen_c_x - message_length/2, screen_bottom/6, 0)
end

function _updateTitle()
  if btnp(4) then shift(1) end
end

function _drawTitle()
	local blink_time = (time()*60)%20
  local blink = blink_time < 10
	local title_length = #Title*4
	local instructions = "Press X to start"
	local instructions_length = #instructions*4
	local footer = "V"..Version.." by "..Author.." "..Date

  cls()
  pal()

  rectfill(0, screen_bottom/8, screen_right, screen_bottom/4, 3)

  print(Title, screen_c_x - title_length/2, screen_bottom/6 + 1, 0)
  print(Title, screen_c_x - title_length/2, screen_bottom/6, 7)

  line(0, screen_bottom/2, screen_right, screen_bottom/2, 1)
  rectfill(0, screen_bottom - 20, screen_right, screen_bottom, 1)
  print(footer,screen_right/16, screen_bottom - 14, 7)

  if blink then pal(7, 6) end
  print(instructions, screen_c_x - instructions_length/2, screen_bottom/2 - 3, blink_color)
end

local shift_t = 0

-- fade animation
function shift(new_state)
	shift_t = 0
	State = 4
	NextState = new_state
	fade(0,-100,8)
end

function _updateShift()
	shift_t = shift_t + 1
	if shift_t > 12 then
		shift_t = 0
		State = NextState
		fade(-100, 0, 8)
	end
end

if configuration.log.enabled then
	log.set_level(configuration.log.level)
	log.init()
end

-- Main initialization function
-- Called once when the program starts
function _init()
	log.info("Initializing application...")

	local success, err = pcall(function()
		-- Initialization logic here
		shift_t = 0
		initGame()
	end)

	if not success then
		wtf(tostring(err))
	end

	log.info("Application initialized successfully.")
end

-- Main update function
-- Called every frame to update the program's State
function _update()
	log.trace("> Entering _update()")

	local success, err = pcall(function()
		-- Update logic here
		if State == 0 then _updateTitle() end
		if State == 1 then _updateGame() end
		if State == 2 then _updateGameOver() end
		if State == 4 then _updateShift() end

		maybe_update_fade()
	end)

	if not success then
		log.error("Error during update: " .. tostring(err))
	end

	log.trace("< Exiting _update()")
end

-- Main draw function
-- Called every frame to render visuals to the screen
function _draw()
	log.trace("> Entering _draw()")

	local success, err = pcall(function()
		-- Draw logic here
		if State == 0 then _drawTitle() end
		if State == 1 then _drawGame() end
		if State == 2 then _drawGameOver() end

		maybe_fade()
	end)

	if not success then
		log.error("Error during draw: " .. tostring(err))
	end

	log.trace("< Exiting _draw()")
end

-----crossfade
local _shex={["0"]=0,["1"]=1,
["2"]=2,["3"]=3,["4"]=4,["5"]=5,
["6"]=6,["7"]=7,["8"]=8,["9"]=9,
["a"]=10,["b"]=11,["c"]=12,
["d"]=13,["e"]=14,["f"]=15}
local _pl={[0]="00000015d67",
     [1]="0000015d677",
     [2]="0000024ef77",
     [3]="000013b7777",
     [4]="0000249a777",
     [5]="000015d6777",
     [6]="0015d677777",
     [7]="015d6777777",
     [8]="000028ef777",
     [9]="000249a7777",
    [10]="00249a77777",
    [11]="00013b77777",
    [12]="00013c77777",
    [13]="00015d67777",
    [14]="00024ef7777",
    [15]="0024ef77777"}
local _pi=0-- -100=>100, remaps spal
local _pe=0-- end pi val of pal fade
local _pf=0-- frames of fade left
function fade(from,to,f)
    _pi=from _pe=to _pf=f
end

function maybe_update_fade ()
 if _pf > 0 then --pal fade
  if _pf == 1 then
   _pi = _pe
  else
   _pi = _pi + ((_pe-_pi)/_pf)
  end
   _pf = _pf - 1
 end
end

function maybe_fade ()
	local pix=6+flr(_pi/20+0.5)
	if(pix ~= 6) then
	    for x=0,15 do
	        pal(x,_shex[sub(_pl[x],pix,pix)],1)
	    end
	else pal() end
end