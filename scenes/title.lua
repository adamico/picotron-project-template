local title = {}
local shift = require("shift")

title.update = function()
  if btnp(5) then shift.init(1) end
end

title.draw = function()
	local blink_time = (time()*60)%20
  local blink = blink_time < 10
	local title_length = #Title*4
	local instructions = "Press X to start"
	local instructions_length = #instructions*4
	local footer = "V"..Version.." by "..Author.." "..Date

  cls()
  pal()

  rectfill(0, Screen.h/8, Screen.w, Screen.h/4, 3)

  print(Title, screen_c_x - title_length/2, Screen.h/6 + 1, 0)
  print(Title, screen_c_x - title_length/2, Screen.h/6, 7)

  line(0, Screen.h/2, Screen.w, Screen.h/2, 1)
  rectfill(0, Screen.h - 20, Screen.w, Screen.h, 1)
  print(footer,Screen.w/16, Screen.h - 14, 7)

  if blink then pal(7, 6) end
  print(instructions, screen_c_x - instructions_length/2, Screen.h/2 - 3, blink_color)
end

return title