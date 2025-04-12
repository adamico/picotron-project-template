add_module_path("entities/")
local playerEntity = require("player")

local cameraLeft = -2.5 * TileSizeX
local cameraTop = -2 * TileSizeY
local cameraWidth = 7.5 * TileSizeX
local cameraHeight = 19 * TileSizeY
World.entity(
  {},
  Box({ x = cameraLeft, y = cameraTop, w = cameraWidth, h = cameraHeight }),
  Follower({
    following = playerEntity,
    within = {
      x1 = 4, offset_x = -9.5, x2 = 24.3,
      y1 = -5, offset_y = -5.125, y2 = 33
    }
  }),
  Position({ x = 0, y = 0 })
)

-- loot (Position, Sprite/Drawable?, Container, Owner/Contained?, Health)
-- explosion (Position, Health?, Animation, Sprite/Drawable?)
-- monsters (Position, Physics, Animation, Health, Box/Size, Sprite/Drawable?, Container, Ai, Shoot, Capture?, Control?)
-- exit? (Position, Animation, Sprite/Drawable?)
-- particle (Position, Physics, Particle, Health, Color, Sprite/Drawable)
-- float (Position, Color, Label)
