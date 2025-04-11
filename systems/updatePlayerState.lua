local buttonsToDir = function()
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

systems.updatePlayerState = World.system({Player}, function(entity)
	local position = entity[Position]
	local fsm = entity[State].machine
	local x = position.x
	local y = position.y
	local dir = entity[Physics].dir
	local player = entity[Player]

	if dir.x == 0.0 and dir.y == 0.0 then
		fsm:stop_moving()
	else
		fsm:move()
	end

	if hover_t and hover_t >= 30 then
		fsm:land()
		hover_t = nil
	end

	if hover_t then hover_t = hover_t + 1 end

	if btn(4) and CanCapture(player.number, x, y) then
		fsm:capture()
	else
		fsm:stop_capturing(player)
	end

  if player.shooting_time < 0 then player.shooting_time = 0 end

  player.shooting_time = max(player.shooting_time - 1, 0)

	if btn(5) and player.shooting_time == 0 then
		player.shooting_dir = buttonsToDir()
		if player.shooting_dir.x ~= 0 or player.shooting_dir.y ~=0 then
			fsm:shoot(player)
		end
	else
		fsm:stop_shooting()
	end
end)