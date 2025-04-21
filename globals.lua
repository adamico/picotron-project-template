--[[pod_format="raw",created="2024-09-08 09:49:37",modified="2025-03-07 13:16:47",revision=5]]
--[[
	globals.lua - global utility functions
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

local wm_pid = 3 -- Process ID of Picotron's window manager and info bar

-- Reports a fatal error, logs the message and traceback, and exits the program.
-- @param message: The format string for the error message
-- @param exit_code: Optional custom exit code (default is 1)
-- @param ...: Additional arguments to format the message
function wtf(message, exit_code, ...)
	local error_report = debug.traceback(string.format(message, ...), 2)

	send_message(wm_pid, { event = "report_error", content = "*wtf?!" })
	send_message(wm_pid, { event = "report_error", content = error_report })

	exit(exit_code or 1)
end

-- Retrieves the process ID (PID) by process name.
-- @param name: The name of the process to search for.
-- @return: The process ID if found, or -1 if not found.
function get_pid_by_name(name)
	local processes = fetch("/ram/system/processes.pod")

	for i = 1, #processes do
		local process = processes[i]
		if (process.name == name) then
			-- Return the process ID if found
			return process.id
		end
	end

	return -1
end

function FlashTo(condition, colors, toColor)
  if condition then
    for n in all(colors) do
      pal(n, toColor)
    end
  else
    pal()
  end
end

ButtonsToDir = function()
	local dir = vec(0,0)
	if btn(0) then
		dir.x = -1
		dir.y = 0
	elseif btn(1) then
		dir.x = 1
		dir.y = 0
	elseif btn(2) then
		dir.x = 0
		dir.y = -1
	elseif btn(3) then
		dir.x = 0
		dir.y = 1
	end
	return dir
end

CanCapture = function(player_number, x, y)
  local tile_number = mget(x, y)
  return tile_number ~= PlayerTiles[player_number]
end


ShallowMerge = function(t1, t2)
  local t3 = {}
  for k,v in pairs(t1) do
    t3[k] = v
  end
  for k,v in pairs(t2) do
    t3[k] = v
  end
  return t3
end

ShallowCopy = function(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

AllElementsBut = function(array, element)
  local array2 = ShallowCopy(array)
  del(array2, element)
  return array2
end

function Distance(actor1, actor2)
	if actor2 == nil then return 9999 end

	local dx = actor1.position.x-actor2.position.x
	local dy = actor1.position.y-actor2.position.y
	return sqrt(dx*dx+dy*dy)
end

function LineOfSight(actor1, actor2)
  return Distance(actor1, actor2) <= actor1.sight
end

function CheckTileFlag(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

function IsCaptured(x, y)
  local captured = false
  for tileNr in all(PlayerTiles) do
    captured = mget(x, y) == tileNr
  end
  return captured
end

function CanMoveTo(x, y)
	return not CheckTileFlag(x, y, 0)
end

function AddDebug(label, value)
	Debug[label] = value
end

function sort(a,cmp)
	for i=1,#a do
			local j = i
			while j > 1 and cmp(a[j-1],a[j]) do
					a[j],a[j-1] = a[j-1],a[j]
			j = j - 1
			end
	end
end

TileSizeX = 24
TileSizeY = 24

Screen = { w=480, h=270 }

screen_c_x = Screen.w/2
screen_c_y = Screen.h/2

PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player
PlayerSounds = {
  captured = 51,
  die = 47,
	hit = 53,
  shooting = 52,
  start_capturing = 50,
	start_engine = 48,
  stop_engine = 49,
}

EnemySounds = {
	hit = 54,
	die = 55
}

GameTitle = "GeoArena"
GameVersion = "0.1"
GameAuthor = "kc00l"
GameDate = date("2020-%Y")