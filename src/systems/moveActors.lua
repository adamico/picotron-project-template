local log = require "log"
local MoveActors = tiny.processingSystem(class('MoveActors'))

function MoveActors:initialize(bumpWorld)
	self.bumpWorld = bumpWorld
end

local checkTileFlag = function(x, y, flag)
	local tile = mget(x, y)
	return fget(tile, flag)
end

local canMoveTo = function(x, y)
	return not checkTileFlag(x, y, 0)
end

MoveActors.filter = tiny.requireAll('actor', 'box', 'physics', 'position')

local function collisionFilter(entity, other_entity)
	if entity.isPlayer then
		if other_entity.isEnemy then return 'cross' end
	end
	return nil
end

function MoveActors:process(entity, _dt)
	local animation = entity.animation
	local physics   = entity.physics
	local position  = entity.position

	local dir = physics.dir

	local new_offset_x, new_offset_y = animation.start_offset_x, animation.start_offset_y
	local goalX, goalY = position.x, position.y

	if animation.offset_t == 0 then
		new_offset_x, new_offset_y = 0, 0
		new_offset_x = TileSizeX * -dir.x
		new_offset_y = TileSizeY * -dir.y
		goalX, goalY = position.x + dir.x, position.y + dir.y
	end

	local cols, len, actualX, actualY
	if (goalX ~= position.x or goalY ~= position.y) and canMoveTo(goalX, goalY) then
		actualX, actualY, cols, len = self.bumpWorld:move(entity, goalX*TileSizeX, goalY*TileSizeY, collisionFilter)
		position.x, position.y = actualX/TileSizeX, actualY/TileSizeX
		animation.start_offset_x = new_offset_x
		animation.start_offset_y = new_offset_y
		animation.offset_t = 1
	end

	if cols then
		for i=1,len do
			local other = cols[i]

			if entity.onCollision then
				entity:onCollision(other)
			end
		end
	end

	animation.offset_t = max(animation.offset_t - animation.offset_speed, 0)
	animation.offset_x = animation.start_offset_x * animation.offset_t
	animation.offset_y = animation.start_offset_y * animation.offset_t
end

function MoveActors:onAdd(entity)
	local position = entity.position
	local box = entity.box
	self.bumpWorld:add(entity, position.x*TileSizeX, position.y*TileSizeY, box.w, box.h)
end

function MoveActors:onRemove(entity)
	self.bumpWorld:remove(entity)
end

return MoveActors