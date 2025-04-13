systems.shoot = World.system({Shoot, Position}, function(entity)
  local position = entity[Position]
  local shoot = entity[Shoot]
  local state = entity[State]

	local fsm = state.machine
  local bullets = shoot.bullets
  local shooting_rate = shoot.rate
  local shooting_speed = shoot.speed

  if btn(5) and shoot.time == 0 then
    shoot.dir = ButtonsToDir()
    if shoot.dir.x ~= 0 or shoot.dir.y ~=0 then
      fsm:shoot(entity)
    end
  else
    fsm:stop_shooting()
  end

  if shoot.time == shooting_rate then
    local bullet = World.entity(
      {name = "bullet"},
      Bullet(),
      Position({
        x = (position.x + 0.5 * shoot.dir.x)*TileSizeX,
        y = (position.y + 0.5 * shoot.dir.y)*TileSizeY
      }),
      Sprite({number = 10}),
      Physics({
        dir = shoot.dir,
        vx = shooting_speed, vy = shooting_speed
      }),
      BelongsTo(entity)
    )
    add(bullets, bullet)
  end

  shoot.time = max(shoot.time - 1, 0)
end)