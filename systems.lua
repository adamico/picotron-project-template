local PlayerTiles = {71, 79, 87, 95} -- dictionary of captured tiles number for each player

local directions = {
	x = {-1, 1, 0, 0, 1, 1, -1, -1},
	y = { 0, 0,-1, 1,-1, 1,  1, -1}
}

local buttonsToDir = function()
	local offset_x, offset_y = 0, 0
	local flip = false
	local dx, dy = 0, 0
	for i=0,3 do
		if btn(i) then
			dx = directions.x[i+1]
			dy = directions.y[i+1]
			offset_x = tile_size_x * -dx
			offset_y = tile_size_y * -dy
			flip = dx < 0
		end
	end

	return dx, dy, offset_x, offset_y, flip
end

local checkTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

local canMoveTo = function(x, y)
	return not checkTileFlag(x, y, 0)
end

-- #systems

local systems = {}

systems.animate = World.system({Sprite, Animation}, function(entity)
	local animation = entity[Animation]
	local sprite = entity[Sprite]
	local sprites = animation.sprites
	local sprite_index = flr((t()*6)%4+1)
	sprite.value = sprites[sprite_index]
end)

systems.move = World.system({Player, Position}, function(entity)
	local position = entity[Position]
	local animation = entity[Animation]
	local player = entity[Player]
	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local new_x, new_y = position.x, position.y
	local dx, dy

	if animation.offset_t == 0 then
		new_offset_x, new_offset_y = 0, 0
		dx, dy, new_offset_x, new_offset_y, animation.flip = buttonsToDir()
		new_x = position.x + dx
		new_y = position.y + dy
	end

	if (new_x ~= position.x or new_y ~= position.y) and
	canMoveTo(new_x, new_y) then
		position.x = mid(0, new_x, 31)
		position.y = mid(0, new_y, 31)
		animation.start_offset_x = new_offset_x
		animation.start_offset_y = new_offset_y
		animation.offset_t = 1
	end

	animation.offset_t = max(animation.offset_t - 0.125, 0)
	player.moving = animation.offset_t > 0
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

	if canCapture(player.number, x, y) then -- this allows account for player size > 1
		add(captured_tiles, { x = x, y = y })
	end

	if #captured_tiles > 0 then
		player.capturing = true
		player.capture_time = player.capture_time + 1 --TODO: add capture power up
	end

	if player.capture_time >= 100 then
		for tile in all(captured_tiles) do
			local tx = tile.x
			local ty = tile.y
			player.capture_time = 0
			Tiles[ty][tx] = PlayerTiles[player.number + 1]
			--TODO: calculate score, current player +1 and tile owner -1
			--TODO: check for loot under captured tile
			log.info(Tiles[ty][tx])
			player.capturing = false
		end
	end
end

systems.handleInput = World.system({Player, Position}, function(entity)
	local player = entity[Player]
	if btn(4) and not player.moving then
		capture(entity)
	else
		systems.move(entity)
		player.capture_time = 0
		player.capturing = false
	end
end)

local drawTile = function(x, y, tile_number)
	local tiles = {}
	-- size
	-- angle stuff
	add(tiles, { val = tile_number, x = x, y = y })

	for tile in all(tiles) do
		mset(tile.x, tile.y, tile.val)
	end
end

local isBetween = function(n, a, b)
	return n > a and n < b
end

systems.drawCapture = World.system({Position, Player}, function(entity)
	local position = entity[Position]
	local player = entity[Player]
	local x, y = position.x, position.y
	local pn = player.number
	-- 0 : 65, 1 : 73, 2 : 81, 3 : 89
	local ctile = 65 + 8 * pn
	local ani_steps = 7
	local ani_factor = 100/ani_steps
	if player.capturing and canCapture(pn, x, y) then
		if player.capture_time < ani_factor then
			drawTile(x, y, ctile) -- TODO: account for player angle here
		elseif isBetween(player.capture_time, ani_factor, ani_factor * 2) then
			drawTile(x, y, ctile + 1)
		elseif isBetween(player.capture_time, ani_factor * 2, ani_factor * 3) then
			drawTile(x, y, ctile + 2)
		elseif isBetween(player.capture_time, ani_factor * 3, ani_factor * 4) then
			drawTile(x, y, ctile + 3)
		elseif isBetween(player.capture_time, ani_factor * 4, ani_factor * 5) then
			drawTile(x, y, ctile + 4)
		elseif isBetween(player.capture_time, ani_factor * 5, ani_factor * 6) then
			drawTile(x, y, ctile + 5)
		elseif isBetween(player.capture_time, ani_factor * 6, ani_factor * 7) then
			drawTile(x, y, ctile + 6)
		end
	end
end)

systems.drawSprites = World.system({Position, Sprite}, function(entity)
	local sprite = entity[Sprite].value
	local animation = entity[Animation]

	palt(30, true)
	palt(0, false)
	spr(sprite,
			entity[Position].x * tile_size_x + animation.offset_x + 2,
			entity[Position].y * tile_size_y + animation.offset_y + 2)
end)

systems.drawPlayerDebug = World.system({Position, Player}, function(entity)
	local player = entity[Player]
	local position = entity[Position]
	local ct = player.capture_time

	if player.capturing then print("capture_time: "..ct, 10, 6, 7) end
	print("Px/y: "..position.x.."/"..position.y, 10, 11, 7)
	print("Moving: "..pod(player.moving), 10, 20, 7)
	print("Tiles: "..pod(Tiles), 10, 30, 7)
	print("PlayerTiles: "..pod(PlayerTiles), 10, 40, 7)
end)

systems.move_camera = World.system({ Follower, Position }, function(entity)
	local player = entity[Follower].following
	local cam_x = mid(
		-2.5 * tile_size_x,
		(player[Position].x - 12.5) * tile_size_x + player[Animation].offset_x,
		7.5 * tile_size_x
	)
	local cam_y = mid(
		-2 * tile_size_y,
		(player[Position].y - 7) * tile_size_y + player[Animation].offset_y,
		19 * tile_size_y
	)

	entity[Position].x = cam_x
	entity[Position].y = cam_y

	camera(cam_x, cam_y)
end)

return systems