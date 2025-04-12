systems.updatePlayerState = World.system({ State }, function(entity)
	local position = entity[Position]
	local fsm = entity[State].machine
	local x = position.x
	local y = position.y
	local dir = entity[Physics].dir
	local player_number = entity[Player].number

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

	if btn(4) and CanCapture(player_number, x, y) then
		fsm:capture()
	else
		fsm:stop_capturing(entity)
	end

  if entity[Shoot].time < 0 then entity[Shoot].time = 0 end

  entity[Shoot].time = max(entity[Shoot].time - 1, 0)

	if btn(5) and entity[Shoot].time == 0 then
		entity[Shoot].dir = ButtonsToDir()
		if entity[Shoot].dir.x ~= 0 or entity[Shoot].dir.y ~=0 then
			fsm:shoot(entity)
		end
	else
		fsm:stop_shooting()
	end
end)