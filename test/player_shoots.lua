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
  Capture({
    time = 0
  }),
	Player({
    number = 0,
    shooting_time = 0,
    shooting_dir = nil
  }),
  State({
    machine = machine.create({
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
          entity[Capture].time = 0
          sfx(-1, 8)
        end
      }
    })
  }),
	Position(),
  Physics(),
  Bullets({list = {}})
)

systems = {}
include("systems/shoot.lua")
include("systems/moveBullets.lua")
include("systems/killBullets.lua")

local fixture = { }

function fixture.before_all()
end

function fixture.before_each()
  playerEntity[Physics].dir = vec(0,0)
	playerEntity[Position].x, playerEntity[Position].y = 1, 1
  playerEntity[Player].shooting_dir = vec(1,0)
  playerEntity[Player].shooting_time = 60
  World.update()
  systems.shoot()
  systems.moveBullets()
end

function fixture.test_player_fires_a_bullet()
  local bullets = playerEntity[Bullets].list
  assert.is_true(#bullets > 0, "Player should have spawned a bullet")
end

function fixture.test_player_bullet_moves()
  local bullets = playerEntity[Bullets].list
  local bullet_position = playerEntity[Position]
  local initial_x, initial_y = bullet_position.x, bullet_position.y
  local dir = playerEntity[Physics].dir

  assert.are_equal(
    bullet_position.x, initial_x + dir.x,
    "Bullet x-coordinate was expected to change from "..bullet_position.x.." to "..initial_x + dir.x)
	assert.are_equal(bullet_position.y, initial_y + dir.y,
    "Bullet y-coordinate was expected to change from "..bullet_position.y.." to "..initial_y + dir.y)
end

function fixture.after_each()
end

function fixture.after_all()
end

return fixture