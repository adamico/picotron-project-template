systems.capture = World.system({Capture}, function(entity)
	local actor = entity[Actor]
	local capture = entity[Capture]
	local position = entity[Position]
	local sound = entity[Sound]
	local state = entity[State]

	local actor_number = actor.id
	local fsm = state.machine

	local tiles_to_capture = {}
	local x = position.x
	local y = position.y

	if (btn(4) and CanCapture(actor_number, x, y)) then
		fsm:capture()
	else
		fsm:stop_capturing(entity)
	end

	-- TODO: account for size

	if fsm:is("capturing") or fsm:is("capturing2") or fsm:is("capturing3") then
		if CanCapture(player_number, x, y) then -- TODO: remove this?
			add(tiles_to_capture, { x = x, y = y })
		end

		if #tiles_to_capture > 0 then
			capture.time = capture.time + capture.power
		end

		if capture.time == 33 then fsm:capture2() end
		if capture.time == 66 then fsm:capture3() end
		if capture.time == 100 then
			fsm:stop_capturing(entity)
			sfx(sound.captured, 8)

			for tile in all(tiles_to_capture) do
				local tx = tile.x
				local ty = tile.y
				mset(tx, ty, PlayerTiles[actor_number])
				entity[Score].captured = entity[Score].captured +1
				--TODO: calculate score, current player +1 and tile owner -1
				--TODO: check for loot under captured tile
			end
			capture.time = 0
		end
	end
end)