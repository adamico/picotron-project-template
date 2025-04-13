local class = require 'lowerclass'

Camera = class('camera')

local cameraLeft = -2.5 * TileSizeX
local cameraTop = -2 * TileSizeY
local cameraWidth = 7.5 * TileSizeX
local cameraHeight = 19 * TileSizeY

function Camera:makeEntity(target)
  return World.entity(
    {},
    Box({ x = cameraLeft, y = cameraTop, w = cameraWidth, h = cameraHeight }),
    Follower({
      following = target,
      within = {
        x1 = 4, offset_x = -9.5, x2 = 24.3,
        y1 = -5, offset_y = -5.125, y2 = 33
      }
    }),
    Position({ x = 0, y = 0 })
  )
end