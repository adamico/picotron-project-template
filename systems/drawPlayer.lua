systems.drawPlayer = World.system({Position, Sprite, Animation}, function(entity)
	local sprite = entity[Sprite].value
	local animation = entity[Animation]
	palt(30, true)
	palt(0, false)

	spr(sprite,
			entity[Position].x * tile_size_x + animation.offset_x,
			entity[Position].y * tile_size_y + animation.offset_y)

end)