local gameover = {}
local shift = require("shift")

gameover.update = function()
	if btnp(5) then shift.init(0) end
end

gameover.draw = function()
	cls(14)
	camera()
	local message = "Game over!"
	local message_length = #message*4
  print(message, screen_c_x - message_length/2, Screen.h/6 + 1, 7)
  print(message, screen_c_x - message_length/2, Screen.h/6, 0)
end

return gameover