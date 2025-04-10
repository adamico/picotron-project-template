systems.move_camera = World.system({ Follower, Position }, function(entity)
	local follower = entity[Follower]
	local player = follower.following
	local within = follower.within

	local cam_x = mid(
		within.x1 * TileSizeX,
		(player[Position].x + within.offset_x) * TileSizeX + player[Animation].offset_x,
		within.x2 * TileSizeX
	)
	local cam_y = mid(
		within.y1 * TileSizeY,
		(player[Position].y + within.offset_y) * TileSizeY + player[Animation].offset_y,
		within.y2 * TileSizeY
	)

	entity[Position].x = cam_x
	entity[Position].y = cam_y

	camera(cam_x, cam_y)
end)