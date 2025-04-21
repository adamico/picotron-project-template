local GameOver = SceneManager:addState('GameOver')

function GameOver:update()
	if btnp(5) then Game:gotoState('Title') end
end

function GameOver:draw()
	cls(14)
	camera()
	local message = "Game over!"
	local message_length = #message*4
  print(message, screen_c_x - message_length/2, Screen.h/6 + 1, 7)
  print(message, screen_c_x - message_length/2, Screen.h/6, 0)
end

function GameOver:enteredState()
	world:clearEntities()
end

function GameOver:exitedState() end

return GameOver