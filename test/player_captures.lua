--[[pod_format="raw",created="2025-03-07 13:17:59",modified="2025-03-07 13:18:32",revision=1]]
--[[
	logview.lua - log viewer utility
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

local assert = require("assert")
local log = require("log")

include("constants.lua")
include("lib/pecs.lua")

World = pecs()
include("components/index.lua")
add_module_path("entities/")

local playerEntity = require("factories.player")

systems = {}
include("systems/capture.lua")

local fixture = { }
local initial_tile_number = 96

function fixture.before_all()
end

function fixture.before_each()
  map = userdata("i16",4,4)
	map:set(1,1,initial_tile_number)
	memmap(map, 0x100000)
  playerEntity[Physics].dir = vec(0,0)
	playerEntity[Position].x, playerEntity[Position].y = 1, 1
  playerEntity[Capture].time = 0
  World.update()
end

function fixture.test_player_captures_a_tile()
	local player_number = playerEntity[Player].number
  local fsm = playerEntity[State].machine
	local captured_tile_number = PlayerTiles[player_number]
	local position = playerEntity[Position]
	x, y = position.x, position.y

	fsm:capture()
	playerEntity[Capture].time = 100
	systems.capture()

	assert.are_equal(mget(x,y), captured_tile_number,
		"Tile "..mget(x,y).." when captured by player " 
    .. player_number.." should change to tile "..captured_tile_number)
end

function fixture.test_player_cannot_capture_his_own_tiles()
	local player_number = playerEntity[Player].number
  local fsm = playerEntity[State].machine
	local captured_tile_number = PlayerTiles[player_number]
	local position = playerEntity[Position]
	x, y = position.x, position.y

	mset(x, y, captured_tile_number)
	fsm:capture()
	playerEntity[Capture].time = 100
	systems.capture()

	assert.is_false(fsm:is("capturing"),
		"Player"..player_number.." should not enter capture mode when on a owned tile")
end

function fixture.after_each()
end

function fixture.after_all()
end

return fixture