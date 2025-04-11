systems.drawPlayer = World.system({Player, Position, Sprite}, function(entity)
	local sprite = entity[Sprite].number
	local animation = entity[Animation]
	palt(30, true)
	palt(0, false)

	spr(sprite,
			entity[Position].x * TileSizeX + animation.offset_x,
			entity[Position].y * TileSizeY + animation.offset_y)
end)