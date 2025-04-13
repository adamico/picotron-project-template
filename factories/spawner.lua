local class = require 'lowerclass'

SpawnerClass = class('spawner')

function SpawnerClass:makeEntity(position_x, position_y, sprite_number)
  return World.entity(
    {name = "spawner"},
    Spawner(),
    Position({ x = position_x, y = position_y }),
    Sprite({number = sprite_number})
  )
end