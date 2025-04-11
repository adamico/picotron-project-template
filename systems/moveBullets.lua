systems.moveBullets = World.system({Bullet, Physics, Position}, function(bullet)
	local physics = bullet[Physics]
	local position = bullet[Position]
	local new_x, new_y = position.x, position.y
	local dir = physics.dir
	new_x = position.x + dir.x*6
	new_y = position.y + dir.y*6

	position.x = new_x
	position.y = new_y
end)