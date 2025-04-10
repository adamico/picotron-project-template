systems.updatePlayerState = World.system({Player}, function(entity)
	local position = entity[Position]
	local player = entity[Player]
	local x = position.x
	local y = position.y
	local dir = player.dir

	if dir.x == 0.0 and dir.y == 0.0 then
		player_fsm:stop_moving()
	else
		player_fsm:move()
	end

	if hover_t and hover_t >= 30 then
		player_fsm:land()
		hover_t = nil
	end

	if hover_t then hover_t = hover_t + 1 end

	if btn(4) and canCapture(player.number, x, y) then
		player_fsm:capture()
	else
		player_fsm:stop_capturing(player)
	end
end)