local class = require 'lowerclass'

BulletClass = class('bullet')

function BulletClass:makeEntity(position_component, shoot_component, owner_entity)
  return World.entity(
    {name = "bullet"},
    Bullet(),
    Position({
      x = (position.x + 0.5 * shoot_component.dir.x)*TileSizeX,
      y = (position.y + 0.5 * shoot_component.dir.y)*TileSizeY
    }),
    Sprite({number = 10}),
    Physics({
      dir = shoot_component.dir,
      vx = shoot_component.speed, vy = shoot_component.speed
    }),
    BelongsTo(owner_entity)
  )
end