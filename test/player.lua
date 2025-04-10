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
local pecs = require("pecs")
local machine = require("statemachine")

include("constants.lua")

World = pecs()


include("components/index.lua")
playerEntity = World.entity(
  { name = "Player" },
  Animation({
    offset_x = 0,
    offset_y = 0,
    start_offset_x = 0,
    start_offset_y = 0,
    offset_t = 0
  }),
	Player({
    number = 0,
    capture_time = 0,
    state = machine.create({
      initial = 'idle',
      events = {
        { name = 'move', 					 	 from = {'idle', 'hovering'}, to = 'moving' },
        { name = 'stop_moving', 	 	 from = 'moving', 						to = 'hovering' },
        { name = 'land', 					 	 from = 'hovering',						to = 'idle' },
        { name = 'capture',  			 	 from = {'idle', 'hovering'},	to = 'capturing' },
        { name = 'stop_capturing', 	 from = 'capturing',				  to = 'idle' }
      },
      callbacks = {
        onentermoving = function(self, event, from, to)
          hover_t = nil
          sfx(Sounds.start_engine, 7)
        end,
        onafterland = function(self, event, from, to)
          sfx(Sounds.stop_engine, 7)
        end,
        onenterhovering = function(self, event, from, to)
          hover_t = 0
        end,
        onaftercapture = function (self, event, from, to)
          sfx(Sounds.start_capturing, 8)
          sfx(-1, 7)
        end,
        onafterstop_capturing = function(self, event, from, to, entity)
          entity.capture_time = 0
          sfx(-1, 8)
        end
      }
    })
  }),
	Position()
)
systems = {}
include("systems/move.lua")
include("systems/capture.lua")

local fixture = { }

function fixture.before_all()
end

function fixture.before_each()
	local player = playerEntity[Player]
	local position = playerEntity[Position]
	player.dir = vec(0,0)
	position.x, position.y = 1, 1
	World.update()
end

function fixture.test_player_moves()
	local position = playerEntity[Position]
	local initial_x, initial_y = position.x, position.y
	local dir = vec(1,0)
	playerEntity[Player].dir = dir
	systems.move()

	assert.are_equal(position.x, initial_x + dir.x, "Player x-coordinate should update correctly")
	assert.are_equal(position.y, initial_y + dir.y, "Player y-coordinate should update correctly")
end

function fixture.test_player_captures_a_tile()
	local player = playerEntity[Player]
	local initial_tile_number = 96
	local captured_tile_number = 71
	local position = playerEntity[Position]
	map = userdata("i16",4,4)
	map:set(1,1,initial_tile_number)
	memmap(map, 0x100000)
	x, y = position.x, position.y
	player.state:capture()
	player.capture_time = 99
	systems.capture()

	assert.are_equal(mget(x,y), captured_tile_number,
		"Tile "..initial_tile_number.." when captured by player " .. player.number.." should change to tile "..captured_tile_number)
end

function fixture.after_each()
end

function fixture.after_all()
end

return fixture