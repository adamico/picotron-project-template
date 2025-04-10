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
}

PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

CanCapture = function(player_number, x, y)
  local tile_number = mget(x, y)
  return tile_number ~= PlayerTiles[player_number+1]
end