local Bullet = class('Bullet')

function Bullet:initialize(position_component, shoot_component, owner_entity)
  self.box      = {x=0, y=0, w=12, h=12}
  self.damage   = owner_entity.gun.power
  self.isBullet = true
  self.physics = {
    dir = shoot_component.dir,
    vx  = shoot_component.speed,
    vy = shoot_component.speed
  }
  self.position = vec(
    (position_component.x + 0.5 * shoot_component.dir.x)*TileSizeX,
    (position_component.y + 0.5 * shoot_component.dir.y)*TileSizeY
  )
  self.sprite  = 10
  self.z_index = 1
end

function Bullet:draw(_dt)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x, self.position.y)
end

function Bullet:die()
  world:remove(self)
end

function Bullet:onCollision(collision)
  local other = collision.other
  if other.isEnemy and other.onHit then
    other:onHit(self.damage)
  end
  self:die()
end

return Bullet