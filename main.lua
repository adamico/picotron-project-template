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
include("lib/require.lua")
include("configuration.lua")

add_module_path("lib/")
add_module_path("scenes/")

local log = require("log")

tile_size_x = 24
tile_size_y = 24

Screen = { w=480, h=270 }

screen_c_x = Screen.w/2
screen_c_y = Screen.h/2

-- Scene Manager
Scene = 0
NextScene = 0

local shift = require("shift")
local title = require("title")
local game = require("game")
local gameover = require("gameover")

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
		game.init()
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
		if Scene == 0 then title.update() end
		if Scene == 1 then game.update() end
		if Scene == 2 then gameover.update() end
		if Scene == 4 then shift.update() end

		shift.maybe_update_fade()
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
		if Scene == 0 then title.draw() end
		if Scene == 1 then game.draw() end
		if Scene == 2 then gameover.draw() end

		shift.maybe_fade()
	end)

	if not success then
		log.error("Error during draw: " .. tostring(err))
	end

	log.trace("< Exiting _draw()")
end