systems.drawPlayer = World.system({Player, Position, Sprite}, function(entity)
	local sprite = entity[Sprite].number
	local position = entity[Position]
	local animation = entity[Animation]

	palt(30, true)
	palt(0, false)

	spr(sprite,
		position.x * TileSizeX + animation.offset_x,
		position.y * TileSizeY + animation.offset_y)
end)