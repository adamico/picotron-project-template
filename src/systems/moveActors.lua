local moveActors = tiny.processingSystem()

local checkTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

local canMoveTo = function(x, y)
	return not checkTileFlag(x, y, 0)
end

moveActors.filter = tiny.requireAll('actor', 'physics', 'position')

function moveActors:process(entity, _dt)
	local animation = entity.animation
	local physics = entity.physics
	local position = entity.position

	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local new_x, new_y = position.x, position.y
	local dir = physics.dir

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

	local move_delta = physics.speed
	animation.offset_t = max(animation.offset_t - move_delta, 0)
	animation.offset_x = animation.start_offset_x * animation.offset_t
	animation.offset_y = animation.start_offset_y * animation.offset_t
end

return moveActors