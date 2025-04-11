systems.drawBullets = World.system({Bullet, Sprite, Position}, function(bullet)
  local position = bullet[Position]
  local sprite = bullet[Sprite].number

	palt(30, true)
	palt(0, false)

  spr(sprite, position.x, position.y)
end)