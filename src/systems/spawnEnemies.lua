local spawnEnemies = ecs.processingSystem(class('SpawnEnemies'))
local Enemy = require('enemy')

spawnEnemies.filter = ecs.requireAll('spawner', 'position')

local function generatePos(enemy)

end

local function randomOffsetFrom(position)
  local previous_positions = {}
  foreach(Enemies, generatePos)
  vec(
    spawner_position.x + flr(rnd(3))+1,
    spawner_position.y + flr(rnd(3))+1
  )
end

function spawnEnemies:process(entity, _dt)
  local spawner_position = entity.position
  while #Enemies < 3 do
    local enemy = Enemy:new(randomOffsetFrom(spawner_position), 15, 15)
    world:add(enemy)
    add(Enemies, enemy)
  end
end

return spawnEnemies