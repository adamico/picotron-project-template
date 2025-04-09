local PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

local machine = require("statemachine")
local m_states = {'m_left', 'm_right', 'm_up', 'm_down' }
local anim_fsm = machine.create({
	initial = 'idle',
	events = {
		{ name = 'move_left',   	 from = {'idle', 'move_right'}, to = 'm_left' },
		{ name = 'move_right',  	 from = {'idle', 'move_left'},  to = 'm_right' },
		{ name = 'move_up',     	 from = {'idle', 'm_down'}, 		to = 'm_up' },
		{ name = 'move_down',   	 from = {'idle', 'm_up'},   		to = 'm_down' },
		{ name = 'stop_moving', 	 from = m_states, 							to = 'idle' },
		{ name = 'capture',  			 from = 'idle', 								to = 'capturing' },
		{ name = 'capture2', 			 from = 'capturing',						to = 'capturing2' },
		{ name = 'capture3', 			 from = 'capturing2',					  to = 'capturing3' },
		{ name = 'stop_capturing', from = 'capturing3',					  to = 'idle' }
	},
	callbacks = {
		onafterstop_capturing = function(self, event, from, to, entity)
			entity.capture_time = 0
		end
	}
})

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

local isMoving = function()
	local state = anim_fsm.current
	return state == "m_left" or state == "m_right" or state == "m_up" or state == "m_down"
end

local isCapturing = function(state)
	return state == "capture" or state == "capture2" or state == "capture3"
end

local sound_states = {
	engine_on = true,
	engine_off = false,
	capturing = true,
	captured = false
}

systems.soundizePlayer = World.system({Player, State}, function(entity)
	if sound_states.engine_on and isMoving() then
		sfx(48, 8)
		sound_states.engine_on = false
		sound_states.engine_off = true
	end

	if sound_states.engine_off and anim_fsm:is("idle") then
		sfx(49, 8)
		sound_states.engine_off = false
		sound_states.engine_on = true
	end

	if sound_states.capturing and isCapturing(state_value) then
		sfx(50, 7)
		sound_states.capturing = false
		sound_states.captured = true
	end

	if sound_states.captured and anim_fsm:is("captured") then
		sfx(51, 7)
		sound_states.capturing = true
		sound_states.captured = false
	end
end)

systems.animatePlayer = World.system({Sprite, Animation, Player}, function(entity)
	local animation = entity[Animation]
	local sprite = entity[Sprite]
	local state = anim_fsm.current
	local player = entity[Player]
	local states_to_sprites = {
		idle = 0,
		m_left = 1,
		m_right = 2,
		m_up = 3,
		m_down = 4,
		capturing = 5,
		capturing2 = 6,
		capturing3 = 7
	}

	sprite.value = states_to_sprites[state]

	-- local sprites = animation.sprites
	-- local sprite_index = flr((t()*6)%4+1)
	-- sprite.value = sprites[sprite_index]
end)

systems.updatePlayerDirection = World.system({Player, State}, function(entity)
	local state = entity[State]
	local player = entity[Player]
	local dir = player.dir

	if dir.x == -1.0 then anim_fsm:move_left() end
	if dir.x == 1.0 then anim_fsm:move_right() end
	if dir.y == -1.0 then anim_fsm:move_up() end
	if dir.y == 1.0 then anim_fsm:move_down() end

	if dir.x == 0.0 and dir.y == 0.0 then anim_fsm:stop_moving() end
end)

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

local canCapture = function(player_number, x, y)
	local tile_number = Tiles[y][x]
	return tile_number ~= PlayerTiles[player_number+1]
end

local capture = function(entity)
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

	if player.capture_time > 0 then
		local capture_steps = 3
		local capture_factor = 100/capture_steps

		if player.capture_time < capture_factor then
			anim_fsm:capture()
		elseif isBetween(player.capture_time, capture_factor, capture_factor*2) then
			anim_fsm:capture2()
		elseif isBetween(player.capture_time, capture_factor*2, 100) then
			anim_fsm:capture3()
		end
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
		anim_fsm:stop_capturing(player)
	end
end

systems.handleInput = World.system({Player, Position}, function(entity)
	local player = entity[Player]
	local state = anim_fsm.current
	player.dir = buttonsToDir()
	if btn(4) and not isMoving() then
	 	capture(entity)
	else
	 	systems.move(entity)
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

	print("Px/y: "..pod(position.x).."/"..pod(position.y), 10, 10, 7)
	print("State: "..pod(anim_fsm.current), 10, 20, 7)
	print("Dir: x"..player.dir.x.."/y"..player.dir.y, 10, 30, 7)
	-- print("Is moving: "..pod(isMoving(state.value)), 10, 20, 7)
	-- print("Dx/y: "..pod(physics.xv).."/"..pod(physics.yv), 10, 20, 7)
	print("Capture time: "..pod(player.capture_time), 10, 40, 7)
	-- print("Tiles: "..pod(Tiles), 10, 30, 7)
	-- print("Sprite: "..pod(sprite), 10, 30, 7)
	-- print("Key0123 "..pod({btn(0),btn(1),btn(2),btn(3)}), 10, 30, 7)
	-- print("AniOffset x/y: "..pod(animation.start_offset_x).."/"..pod(animation.start_offset_y), 10, 30, 7)
	-- print("play engine on: "..pod(play_engine_on), 10, 40, 7)
	-- print("play engine off: "..pod(play_engine_off), 10, 50, 7)
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