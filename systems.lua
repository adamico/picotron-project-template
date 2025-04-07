local PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

local buttonsToDir = function(entity)
	local state = entity[State]
	local offset_x, offset_y = 0, 0
	local flip_h, flip_v = false, false
	local dx, dy = 0, 0

	if btn(0) then
		dx = -1
		dy = 0
		state.value = "m_left"
	elseif btn(1) then
		dx = 1
		dy = 0
		state.value = "m_right"
	elseif btn(2) then
		dx = 0
		dy = -1
		state.value = "m_up"
	elseif btn(3) then
		dx = 0
		dy = 1
		state.value = "m_down"
	else
		state.value = "idle"
	end
	offset_x = tile_size_x * -dx
	offset_y = tile_size_y * -dy
	flip_h = dx < 0
	flip_v = dy < 0

	return dx, dy, offset_x, offset_y, flip_h, flip_v
end

local checkTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

local canMoveTo = function(x, y)
	return not checkTileFlag(x, y, 0)
end

local isBetween = function(n, a, b)
	return n > a and n < b
end

local systems = {}

systems.animatePlayer = World.system({Sprite, Animation, Player}, function(entity)
	local animation = entity[Animation]
	local sprite = entity[Sprite]
	local state = entity[State]
	local player = entity[Player]
	local states_to_sprites = {
		idle = 0,
		m_left = 1,
		m_right = 2,
		m_up = 3,
		m_down = 4,
		capture = 5,
		capture2 = 6,
		capture3 = 7
	}

	local new_state_value = state.value
	if player.capture_time > 0 then
		local capture_ani_steps = 3
		local capture_ani_factor = 100/capture_ani_steps

		if player.capture_time < capture_ani_factor then
			new_state_value = "capture"
		elseif isBetween(player.capture_time, capture_ani_factor, capture_ani_factor*2) then
			new_state_value = "capture2"
		elseif isBetween(player.capture_time, capture_ani_factor*2, 100) then
			new_state_value = "capture3"
		end
	end

	sprite.value = states_to_sprites[new_state_value]

	-- local sprites = animation.sprites
	-- local sprite_index = flr((t()*6)%4+1)
	-- sprite.value = sprites[sprite_index]
end)

systems.move = World.system({Player, Position}, function(entity)
	local position = entity[Position]
	local animation = entity[Animation]
	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local new_x, new_y = position.x, position.y
	local dx, dy

	if animation.offset_t == 0 then
		new_offset_x, new_offset_y = 0, 0
		dx, dy, new_offset_x, new_offset_y, animation.flip_h, animation.flip_v = buttonsToDir(entity)
		new_x = position.x + dx
		new_y = position.y + dy
	end

	if (new_x ~= position.x or new_y ~= position.y) and
	canMoveTo(new_x, new_y) then
		position.x = new_x
		position.y = new_y
		animation.start_offset_x = new_offset_x
		animation.start_offset_y = new_offset_y
		animation.offset_t = 1
	end

	local move_delta = 0.06 -- TODO: speed power
	animation.offset_t = max(animation.offset_t - move_delta, 0)
	animation.offset_x = animation.start_offset_x * animation.offset_t
	animation.offset_y = animation.start_offset_y * animation.offset_t
end)

local canCapture = function(player_number, x, y)
	local tile_number = Tiles[y][x]
	return tile_number ~= PlayerTiles[player_number+1]
end

local capture = function(entity)
	local position = entity[Position]
	local player = entity[Player]

	local x = position.x
	local y = position.y
	local captured_tiles = {}

	if canCapture(player.number, x, y) then -- TODO: size up
		add(captured_tiles, { x = x, y = y })
	end

	if #captured_tiles > 0 then
		player.capture_time = player.capture_time + 1 --TODO: capture power up
	end

	if player.capture_time >= 100 then
		for tile in all(captured_tiles) do
			local tx = tile.x
			local ty = tile.y
			player.capture_time = 0
			Tiles[ty][tx] = PlayerTiles[player.number + 1]
			mset(tx, ty, PlayerTiles[player.number + 1])
			--TODO: calculate score, current player +1 and tile owner -1
			--TODO: check for loot under captured tile
		end
	end
end

local isMoving = function(state)
	return state == "m_left" or state == "m_right" or state == "m_up" or state == "m_down"
end

systems.handleInput = World.system({Player, Position}, function(entity)
	local player = entity[Player]
	local state = entity[State]
	local s_val = state.value
	if btn(4) and not isMoving(s_val) then
		capture(entity)
	else
		systems.move(entity)
		player.capture_time = 0
	end
end)

systems.drawPlayer = World.system({Position, Sprite, Animation}, function(entity)
	local sprite = entity[Sprite].value
	local animation = entity[Animation]
	palt(30, true)
	palt(0, false)

	spr(sprite,
			entity[Position].x * tile_size_x + animation.offset_x,
			entity[Position].y * tile_size_y + animation.offset_y)

end)

systems.drawPlayerDebug = World.system({Position, Player, Physics, Animation}, function(entity)
	local player = entity[Player]
	local position = entity[Position]
	local physics = entity[Physics]
	local animation = entity[Animation]
	local state = entity[State]
	local ct = player.capture_time
	local sprite = entity[Sprite].value

	if player.capturing then print("capture_time: "..ct, 10, 6, 7) end
	print("Px/y: "..pod(position.x).."/"..pod(position.y), 10, 11, 7)
	print("State: "..pod(state.value), 10, 20, 7)
	-- print("Dx/y: "..pod(physics.xv).."/"..pod(physics.yv), 10, 20, 7)
	print("Capture time: "..pod(player.capture_time), 10, 30, 7)
	-- print("Tiles: "..pod(Tiles), 10, 30, 7)
	-- print("Sprite: "..pod(sprite), 10, 30, 7)
	-- print("Key0123 "..pod({btn(0),btn(1),btn(2),btn(3)}), 10, 30, 7)
	-- print("AniOffset x/y: "..pod(animation.start_offset_x).."/"..pod(animation.start_offset_y), 10, 30, 7)
	-- print("PlayerTiles: "..pod(PlayerTiles), 10, 40, 7)
	-- print("Flip h/v: "..pod(animation.flip_h).."/"..pod(animation.flip_v), 10, 40, 7)

end)

systems.move_camera = World.system({ Follower, Position }, function(entity)
	local follower = entity[Follower]
	local player = follower.following
	local within = follower.within

	local cam_x = mid(
		within.x1 * tile_size_x,
		(player[Position].x + within.offset_x) * tile_size_x + player[Animation].offset_x,
		within.x2 * tile_size_x
	)
	local cam_y = mid(
		within.y1 * tile_size_y,
		(player[Position].y + within.offset_y) * tile_size_y + player[Animation].offset_y,
		within.y2 * tile_size_y
	)

	entity[Position].x = cam_x
	entity[Position].y = cam_y

	camera(cam_x, cam_y)
end)

-- playerShoot(Player, Position) -- instantiate player bullet entities
-- monsterShoot(Player, Position) -- instantiate monster bullet entities
-- collision()
-- spawnMonsters()
-- spawnLoot()
-- checkPlayerProtected()
-- checkPlayerForm()
-- playerTurn
-- doGameOver()
-- harmLoot()
-- executeMonsterAi()
-- getPowerUp()
-- doEndLevel()

-- drawPowerups()
-- drawParticles()
-- drawFloats()
-- drawUi()

return systems