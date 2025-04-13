systems.drawActors = World.system({Actor, Position, Sprite, Animation, State}, function(entity)
	local actor = entity[Actor]
	local animation = entity[Animation]
	local position = entity[Position]
	local sprite = entity[Sprite]
	local state = entity[State].machine.current

	palt(30, true)
	palt(0, false)

	entity[Sprite].number = animation.statesToSprites[state]
	local offset = actor.type == 'player' and {x = animation.offset_x, y = animation.offset_y } or vec(0,0)
	spr(sprite.number,
		position.x * TileSizeX + offset.x,
		position.y * TileSizeY + offset.y)
end)