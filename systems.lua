local PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

local machine = require("statemachine")

local sounds = {
	start_engine = 48,
	stop_engine = 49,
	start_capturing = 50,
	captured = 51,
}

local player_fsm = machine.create({
	initial = 'idle',
	events = {
		{ name = 'move', 					 	 from = {'idle', 'hovering'}, to = 'moving' },
		{ name = 'stop_moving', 	 	 from = 'moving', 						to = 'hovering' },
		{ name = 'land', 					 	 from = 'hovering',						to = 'idle' },
		{ name = 'capture',  			 	 from = {'idle', 'hovering'},	to = 'capturing' },
		{ name = 'stop_capturing', 	 from = 'capturing',				  to = 'idle' }
	},
	callbacks = {
		onentermoving = function(self, event, from, to)
			hover_t = nil
			sfx(sounds.start_engine, 7)
		end,
		onafterland = function(self, event, from, to)
			sfx(sounds.stop_engine, 7)
		end,
		onenterhovering = function(self, event, from, to)
			hover_t = 0
		end,
		onaftercapture = function (self, event, from, to)
			sfx(sounds.start_capturing, 8)
			sfx(-1, 7)
		end,
		onafterstop_capturing = function(self, event, from, to, entity)
			entity.capture_time = 0
			sfx(-1, 8)
		end
	}
})

local buttonsToDir = function()
	local dir = vec(0,0)

	if not btn(4) then
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
	end

	return dir
end

local systems = {}

local stateForDir = function(dir)
	local state
	if dir.x == -1 then state = "m_left" end
	if dir.x == 1  then state = "m_right" end
	if dir.y == -1 then state = "m_up" end
	if dir.y == 1  then state = "m_down" end

	return state
end

local isBetween = function(n, a, b)
	return n >= a and n < b
end

local stateForCapture = function(capture_time)
	local state
	if isBetween(capture_time, 0, 33) then state = "capturing"
	elseif isBetween(capture_time, 33, 66) then state = "capturing2"
	elseif isBetween(capture_time, 66, 100) then state = "capturing3"
	else
		state = "idle"
	end

	return state
end

systems.animatePlayer = World.system({Sprite, Animation, Player}, function(entity)
	local animation = entity[Animation]
	local sprite = entity[Sprite]
	local state = player_fsm.current
	local player = entity[Player]
	local spriteNumbersForStates = {
		idle = 0,
		m_left = 1,
		m_right = 2,
		m_up = 3,
		m_down = 4,
		hovering = 8,
		capturing = 5,
		capturing2 = 6,
		capturing3 = 7
	}

	local new_sprite_value
	if state == 'moving' then
		new_sprite_value = spriteNumbersForStates[stateForDir(player.dir)]
	elseif state == 'capturing' then
		new_sprite_value = spriteNumbersForStates[stateForCapture(player.capture_time)]
	else
		new_sprite_value = spriteNumbersForStates[state]
	end

	sprite.value = new_sprite_value
	-- local sprites = animation.sprites
	-- local sprite_index = flr((t()*6)%4+1)
	-- sprite.value = sprites[sprite_index]
end)

local canCapture = function(player_number, x, y)
	local tile_number = Tiles[y][x]
	return tile_number ~= PlayerTiles[player_number+1]
end

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

local checkTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

local canMoveTo = function(x, y)
	return not checkTileFlag(x, y, 0)
end

systems.move = World.system({Player, Position}, function(entity)
	local player = entity[Player]
	local position = entity[Position]
	local animation = entity[Animation]
	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local new_x, new_y = position.x, position.y
	local dir = player.dir

	if animation.offset_t == 0 then
		new_offset_x, new_offset_y = 0, 0
		new_offset_x = tile_size_x * -dir.x
		new_offset_y = tile_size_y * -dir.y
		new_x = position.x + dir.x
		new_y = position.y + dir.y
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
			Tiles[ty][tx] = PlayerTiles[player.number + 1]
			mset(tx, ty, PlayerTiles[player.number + 1])
			--TODO: calculate score, current player +1 and tile owner -1
			--TODO: check for loot under captured tile
		end
		player_fsm:stop_capturing(player)
		sfx(sounds.captured, 8)
	end
end)

systems.handleInput = World.system({Player, Position}, function(entity)
	local player = entity[Player]
	player.dir = buttonsToDir() --TODO: account for player number
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

	print("Px/y: "..pod(position.x).."/"..pod(position.y), 10, 10, 7)
	print("State: "..pod(player_fsm.current), 10, 20, 7)
	print("Dir: x"..player.dir.x.."/y"..player.dir.y, 10, 30, 7)
	-- print("Is moving: "..pod(isMoving(state.value)), 10, 20, 7)
	-- print("Dx/y: "..pod(physics.xv).."/"..pod(physics.yv), 10, 20, 7)
	print("Capture time: "..pod(player.capture_time), 10, 40, 7)
	-- print("Tiles: "..pod(Tiles), 10, 30, 7)
	-- print("Sprite: "..pod(sprite), 10, 30, 7)
	-- print("Key0123 "..pod({btn(0),btn(1),btn(2),btn(3)}), 10, 30, 7)
	-- print("AniOffset x/y: "..pod(animation.start_offset_x).."/"..pod(animation.start_offset_y), 10, 40, 7)
	-- print("AniOffset t: "..pod(animation.offset_t), 10, 50, 7)
	-- print("play engine on: "..pod(play_start_engine), 10, 40, 7)
	-- print("hover_t: "..pod(hover_t), 10, 40, 7)
	-- print("play engine off: "..pod(play_stop_engine), 10, 50, 7)
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