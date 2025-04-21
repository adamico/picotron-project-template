local MoveBullets = tiny.processingSystem(class('MoveBullets'))

MoveBullets.filter = tiny.requireAll('isBullet')

local function collisionFilter(entity, other_entity)
	if other_entity.isEnemy then return 'cross' end
	return nil
end

function MoveBullets:initialize(bumpWorld)
	self.bumpWorld = bumpWorld
end

function MoveBullets:process(entity, _dt)
	local physics = entity.physics
	local position = entity.position

	local dir = physics.dir
	local goalX = position.x + dir.x * physics.vx
	local goalY = position.y + dir.y * physics.vy

	local actualX, actualY, cols, len = self.bumpWorld:move(
		entity, goalX, goalY, collisionFilter
	)

	position.x = actualX
	position.y = actualY

	if cols then
		for i=1,len do
			local collision = cols[i]

			if entity.onCollision then entity:onCollision(collision) end
		end
	end
end

function MoveBullets:onAdd(entity)
	local position = entity.position
	local box = entity.box
	self.bumpWorld:add(entity, position.x, position.y, box.w, box.h)
end

function MoveBullets:onRemove(entity)
	self.bumpWorld:remove(entity)
end

return MoveBullets