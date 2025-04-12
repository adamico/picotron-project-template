systems.shoot = World.system({Shoot, Position}, function(entity)
  local position = entity[Position]
  local shoot = entity[Shoot]
  local bullets = shoot.bullets
  local dir = shoot.dir
  local shooting_rate = shoot.rate
	local fsm = entity[State].machine
  local shooting_speed = shoot.speed
  if not dir then return end

  if dir.x == 0.0 and dir.y == 0.0 then
    fsm:stop_shooting()
  else
    if shoot.time == shooting_rate then
      local bullet = World.entity(
        {name = "bullet"},
        Sprite({number = 16}),
        Position({
          x = (position.x + 0.5 * dir.x)*TileSizeX,
          y = (position.y + 0.5 * dir.y)*TileSizeY
        }),
        Bullet(),
        Physics({dir = dir, vx = shooting_speed, vy = shooting_speed}),
        BelongsTo(entity)
      )
      add(bullets, bullet)
    end
  end
end)