local moveBullets = tiny.processingSystem()

moveBullets.filter = tiny.requireAll('bullet')

local function collisionFilter(entity, other_entity)
	if other_entity.isEnemy then return 'cross' end
	return nil
end

function moveBullets:process(entity, _dt)
	local physics = entity.physics
	local position = entity.position

	local dir = physics.dir
	local goalX = position.x + dir.x * physics.vx
	local goalY = position.y + dir.y * physics.vy

	local actualX, actualY, cols, len = bumpWorld:move(
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

function moveBullets:onAdd(entity)
	local position = entity.position
	local box = entity.box
	bumpWorld:add(entity, position.x, position.y, box.w, box.h)
end

function moveBullets:onRemove(entity)
	bumpWorld:remove(entity)
end

return moveBullets