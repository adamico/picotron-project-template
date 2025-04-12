systems.drawBullets = World.system({Bullet, Position, Sprite}, function(entity)
  local sprite = entity[Sprite].number
  local position = entity[Position]

	palt(30, true)
	palt(0, false)

  spr(sprite,
    position.x,
    position.y)
end)