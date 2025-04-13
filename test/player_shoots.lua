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
include("lib/pecs.lua")

include("constants.lua")

World = pecs()
include("components/index.lua")
add_module_path("entities/")
local playerEntity = require("factories.player")

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
  playerEntity[Shoot].dir = vec(1,0)
  playerEntity[Shoot].time = 60
  World.update()
  systems.shoot()

end

function fixture.test_player_fires_a_bullet()
  local bullets = playerEntity[Shoot].bullets

  assert.is_true(#bullets > 0, "Player should have spawned a bullet")
end

function fixture.test_player_bullet_moves()
  local bullet_position = playerEntity[Position]
  local initial_x, initial_y = bullet_position.x, bullet_position.y
  local dir = playerEntity[Physics].dir
  systems.moveBullets()
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