local Enemy  = require('enemy')
local chance = require('chance')

Spawner      = class('Spawner')

function Spawner:initialize(position, sprite_number)
  self.canSpawn       = true
  self.isSpawner      = true
  self.position       = position
  self.spawnedEnemies = {}
  self.sprite         = sprite_number
  self.z_index        = 2
end

function Spawner:draw(_dt)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x*TileSizeX, self.position.y*TileSizeY)
end

local function randomPositions(position)
  local positions = {x = {}, y = {}}
  for x=position.x - 2, position.x + 2 do
    add(positions.x, x)
  end
  for y=position.y - 2, position.y + 2 do
    add(positions.y, y)
  end
  return positions
end

function Spawner:spawn(_dt)
  if #self.spawnedEnemies < 3 and self.canSpawn then
    local positions = randomPositions(self.position)
    local xs = chance.helpers.shuffle(positions.x)
    local ys = chance.helpers.shuffle(positions.y)
    local position = vec(xs[1], ys[1])

    local enemy = Enemy:new(position, 8, 8)
    enemy.belongsTo = self
    world:add(enemy)
    add(self.spawnedEnemies, enemy)
    self.canSpawn = false
    Timer.after(rnd(3)+1, function() self.canSpawn = true end)
  end
end

return Spawner