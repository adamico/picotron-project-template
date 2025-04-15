local Bullet = class('Bullet')

function Bullet:initialize(position_component, shoot_component, owner_entity)
  self.bullet = {}
  self.position = vec(
    (position_component.x + 0.5 * shoot_component.dir.x)*TileSizeX,
    (position_component.y + 0.5 * shoot_component.dir.y)*TileSizeY
  )
  self.sprite = 10
  self.physics = {
    dir = shoot_component.dir,
    vx = shoot_component.speed, vy = shoot_component.speed
  }
  self.belongsTo = owner_entity
end

function Bullet:draw(_dt)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x, self.position.y)
end

return Bullet