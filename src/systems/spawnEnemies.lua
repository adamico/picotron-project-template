local spawnEnemies = tiny.processingSystem()

spawnEnemies.filter = tiny.requireAll('isSpawner')

function spawnEnemies:process(spawner, _dt)
  spawner:spawn()
end

return spawnEnemies