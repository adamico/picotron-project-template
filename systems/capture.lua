player_fsm = require("player_fsm")

systems.capture = World.system({Player, Position}, function(entity)
	if not player_fsm:is("capturing") then return end
	local position = entity[Position]
	local player = entity[Player]
	local x = position.x
	local y = position.y
	local tiles_to_capture = {}

	if canCapture(player.number, x, y) then -- TODO: account for size
		add(tiles_to_capture, { x = x, y = y })
	end

	if #tiles_to_capture > 0 then
		player.capture_time = player.capture_time + 1 --TODO: account for capture power up
	end

	if player.capture_time >= 100 then
		for tile in all(tiles_to_capture) do
			local tx = tile.x
			local ty = tile.y
			mset(tx, ty, PlayerTiles[player.number + 1])
			--TODO: calculate score, current player +1 and tile owner -1
			--TODO: check for loot under captured tile
		end
		player_fsm:stop_capturing(player)
		sfx(sounds.captured, 8)
	end
end)