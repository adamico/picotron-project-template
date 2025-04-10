systems.move_camera = World.system({ Follower, Position }, function(entity)
	local follower = entity[Follower]
	local player = follower.following
	local within = follower.within

	local cam_x = mid(
		within.x1 * tile_size_x,
		(player[Position].x + within.offset_x) * tile_size_x + player[Animation].offset_x,
		within.x2 * tile_size_x
	)
	local cam_y = mid(
		within.y1 * tile_size_y,
		(player[Position].y + within.offset_y) * tile_size_y + player[Animation].offset_y,
		within.y2 * tile_size_y
	)

	entity[Position].x = cam_x
	entity[Position].y = cam_y

	camera(cam_x, cam_y)
end)