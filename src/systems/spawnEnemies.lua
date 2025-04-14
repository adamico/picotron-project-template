include("src/factories/enemy.lua")

systems.spawnEnemies = World.system({Spawner, Position}, function(entity)
  local position = entity[Position]

  while #Enemies < 3 do
    local enemy = Enemy:new()
    enemyEntity = enemy:makeEntity(position)
    add(Enemies, enemyEntity)
  end
end)