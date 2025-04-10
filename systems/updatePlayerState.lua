systems.updatePlayerState = World.system({Player}, function(entity)
	local position = entity[Position]
	local player = entity[Player]
	local fsm = player.state
	local x = position.x
	local y = position.y
	local dir = player.dir

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
end)