local chance = require('chance')

local spawnEnemies = ecs.processingSystem()
local Enemy = require('enemy')

spawnEnemies.filter = ecs.requireAll('spawner', 'position')

function spawnEnemies:process(entity, _dt)
  local spawner_position = entity.position
  local enemy_positions = {x = {}, y = {}}
  for x=spawner_position.x - 2, spawner_position.x + 2 do
    add(enemy_positions.x, x)
  end
  for y=spawner_position.y - 2, spawner_position.y + 2 do
    add(enemy_positions.y, y)
  end

  while #Enemies < 3 do
    local xs = chance.helpers.shuffle(enemy_positions.x, 3)
    local ys = chance.helpers.shuffle(enemy_positions.y, 3)
    local position = vec(xs[1], ys[1])
    local enemy = Enemy:new(position, 15, 15)
    world:add(enemy)
    add(Enemies, enemy)
  end
end

return spawnEnemies