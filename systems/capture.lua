systems.capture = World.system({Capture, Position}, function(entity)
	local position = entity[Position]
	local player_number = entity[Player].number
	local capture_time = entity[Capture].time
	local capture_power = entity[Capture].power
	local fsm = entity[State].machine
	local x = position.x
	local y = position.y
	local tiles_to_capture = {}

	if not fsm:is("capturing") then return end

	-- TODO: account for size
	if CanCapture(player_number, x, y) then -- TODO: remove this?
		add(tiles_to_capture, { x = x, y = y })
	end

	if #tiles_to_capture > 0 then
		entity[Capture].time = entity[Capture].time + capture_power
	end

	if capture_time >= 100 then
		for tile in all(tiles_to_capture) do
			local tx = tile.x
			local ty = tile.y
			mset(tx, ty, PlayerTiles[player_number])
			--TODO: calculate score, current player +1 and tile owner -1
			--TODO: check for loot under captured tile
		end
		fsm:stop_capturing(entity)
		sfx(Sounds.captured, 8)
	end
end)