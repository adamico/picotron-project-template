local spawner = World.entity(
  {name = "spawner"},
  Spawner(),
  Position({ x = 15, y = 15 }),
  Sprite({number = 64})
)

return spawner