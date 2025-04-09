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

tile_size_x = 24
tile_size_y = 24
screen_left = 0
screen_right = 480

screen_top = 0
screen_bottom = 270
screen_c_x = screen_right/2
screen_c_y = screen_bottom/2
grid_columns = screen_right/tile_size_x
grid_rows = screen_bottom/tile_size_y


-- State machine
Scene = 0
NextScene = 0

Map = nil
Tiles = {} -- records captured tiles

local play_music = false

if configuration.log.enabled then
	log.set_level(configuration.log.level)
	log.init()
end

local initLevel = function()
	for y=9,39 do
		local xs = {}
		for x=9,39 do
			local tile = mget(x, y)
			add(xs, tile)
		end
		add(Tiles, xs)
	end

	Map = fetch("map/level1.map")[1].bmp
	memmap(Map, 0x100000)
end

local initGame = function()
	World = pecs()
	include("components.lua")
	include("entities.lua")
	systems = require("systems")
	initLevel()
end

-- main functions for Scenes

function _updateGame()
	if play_music then music(0, 1000) play_music = false end
	World.update()
	systems.handleInput()
	systems.updatePlayerDirection()
	systems.animatePlayer()
	-- systems.soundizePlayer()
end

function _drawGame()
	cls(1)
	systems.move_camera()
	pal(0, false)
	map(0, 0, 0, 0, 48, 48, 0, tile_size_x, tile_size_y)
	systems.drawPlayer()
	camera()
	-- drawUI()
	-- print("cpu:"..flr(stat(1)*100), 10, 1, 7)
	systems.drawPlayerDebug()
end

function _updateGameOver()
	if btnp(4) then Scene = 0 end
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
function shift(new_scene)
	shift_t = 0
	Scene = 4
	NextScene = new_scene
	fade(0,-100,8)
end

function _updateShift()
	shift_t = shift_t + 1
	if shift_t > 12 then
		shift_t = 0
		Scene = NextScene
		fade(-100, 0, 8)
	end
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
		if Scene == 0 then _updateTitle() end
		if Scene == 1 then _updateGame() end
		if Scene == 2 then _updateGameOver() end
		if Scene == 4 then _updateShift() end

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
		if Scene == 0 then _drawTitle() end
		if Scene == 1 then _drawGame() end
		if Scene == 2 then _drawGameOver() end

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

function maybe_update_fade()
 if _pf > 0 then --pal fade
  if _pf == 1 then
   _pi = _pe
  else
   _pi = _pi + ((_pe-_pi)/_pf)
  end
   _pf = _pf - 1
 end
end

function maybe_fade()
	local pix=6+flr(_pi/20+0.5)
	if(pix ~= 6) then
	    for x=0,15 do
	        pal(x,_shex[sub(_pl[x],pix,pix)],1)
	    end
	else pal() end
end