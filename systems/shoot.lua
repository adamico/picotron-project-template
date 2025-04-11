systems.shoot = World.system({Player, Position}, function(entity)
  local player = entity[Player]
  local position = entity[Position]
  local bullets = entity[Bullets]
  local dir = player.shooting_dir
	local fsm = entity[State].machine

  if not dir then return end

  if dir.x == 0.0 and dir.y == 0.0 then
    fsm:stop_shooting()
  else
    if player.shooting_time == 60 then --TODO: account for shoot power
      local bullet = World.entity(
        {name = "bullet"},
        Sprite({number = 16}),
        Position({
          x = (position.x + 0.5 * dir.x)*TileSizeX,
          y = (position.y + 0.5 * dir.y)*TileSizeY
        }),
        Bullet(),
        Physics({dir = dir}),
        BelongsTo(entity)
      )
      add(bullets.list, bullet)
    end
  end
end)