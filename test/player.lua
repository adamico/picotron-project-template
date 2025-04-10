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

local world = pecs()
include("components.lua")


local playerEntity

local systems = require("systems.index")

local fixture = { }

function fixture.before_all()
end

function fixture.before_each()
	playerEntity = world.entity({ name = "Player" },
		Animation({
			offset_x = 0,
			offset_y = 0,
			start_offset_x = 0,
			start_offset_y = 0,
			offset_t = 0,
			flip = false,
			sprites = {1, 2, 3, 4}
		}),
		Box({ x = 0, y = 0, w = playerWidth, h = playerHeight }),
		Player({number = 0}),
		Position({ x = 1, y = 1 }),
		Sprite({ value = 1 })
	)
end

function fixture.test_player_moves()
end

function fixture.test_something2()
end

function fixture.after_each()
end

function fixture.after_all()
end

return fixture