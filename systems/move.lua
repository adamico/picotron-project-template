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
		new_offset_x = TileSizeX * -dir.x
		new_offset_y = TileSizeY * -dir.y
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