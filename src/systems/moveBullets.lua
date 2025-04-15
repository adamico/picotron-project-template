local moveBullets = ecs.processingSystem()

moveBullets.filter = ecs.requireAll('bullet')

function moveBullets:process(entity, _dt)
	local physics = entity.physics
	local position = entity.position
	local new_x, new_y = position.x, position.y
	local dir = physics.dir
	new_x = position.x + dir.x * physics.vx
	new_y = position.y + dir.y * physics.vy

	position.x = new_x
	position.y = new_y
end

return moveBullets