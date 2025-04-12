TileSizeX = 24
TileSizeY = 24

Screen = { w=480, h=270 }

screen_c_x = Screen.w/2
screen_c_y = Screen.h/2

Sounds = {
  start_engine = 48,
  stop_engine = 49,
  start_capturing = 50,
  captured = 51,
  shooting = 52
}

PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

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