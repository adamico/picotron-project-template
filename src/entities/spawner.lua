Spawner = class('Spawner')

function Spawner:initialize(position, sprite_number)
  self.spawner = true
  self.position = position
  self.sprite = sprite_number
  self.z_index = 2
end

function Spawner:draw(_dt)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x*TileSizeX, self.position.y*TileSizeY)

end

return Spawner