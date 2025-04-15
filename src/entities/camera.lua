local class = require 'middleclass'

Camera = class('Camera')

local cameraLeft = -2.5 * TileSizeX
local cameraTop = -2 * TileSizeY
local cameraWidth = 7.5 * TileSizeX
local cameraHeight = 19 * TileSizeY

function Camera:initialize(target)
  self.box = {x=cameraLeft, y=cameraTop, w=cameraWidth, h=cameraHeight}
  self.target = target
  self.within = {
    x1=4,  offset_x=-9.5,   x2=24.3,
    y1=-5, offset_y=-5.125, y2=33
  }
  self.position = vec(0,0)
end

function Camera:update()
  local player = self.target
  local within = self.within

  local cam_x = mid(
		within.x1 * TileSizeX,
		(player.position.x + within.offset_x) * TileSizeX + player.animation.offset_x,
		within.x2 * TileSizeX
	)
	local cam_y = mid(
		within.y1 * TileSizeY,
		(player.position.y + within.offset_y) * TileSizeY + player.animation.offset_y,
		within.y2 * TileSizeY
	)

  self.position = vec(cam_x, camy)
  camera(cam_x, cam_y)
end

return Camera