systems.spawnEnemies = World.system({Spawner}, function(entity)
  local position = entity[Position]
  if #Enemies < 3 then
    local enemy = World.entity(
      {name = "enemy"},
      Enemy(),
      Sprite({number = 18}),
      Position({
        x = position.x + flr(rnd(4)),
        y = position.y + flr(rnd(4))
      })
    )
    add(Enemies, enemy)
  end
end)