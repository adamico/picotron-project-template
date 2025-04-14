systems.moveBullets = World.system({Bullet, Physics, Position}, function(entity)
	local physics = entity[Physics]
	local position = entity[Position]
	local new_x, new_y = position.x, position.y
	local dir = physics.dir
	new_x = position.x + dir.x * physics.vx
	new_y = position.y + dir.y * physics.vy

	position.x = new_x
	position.y = new_y
end)