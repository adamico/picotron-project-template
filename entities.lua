local playerWidth, playerHeight = 15, 15
local playerEntity = World.entity(
  { name = "Player" },
  Animation({
    offset_x = 0,
    offset_y = 0,
    start_offset_x = 0,
    start_offset_y = 0,
    offset_t = 0,
    flip_h = false,
    flip_v = false,
    sprites = {1, 2, 3, 4},
  }),
  Box({ x = 0, y = 0, w = playerWidth, h = playerHeight} ),
  Player({number = 0}),
  Physics({ xv = 0, yv = 0}),
  Position({ x = 9, y = 9 }), -- TODO: set this for each level
  Sprite({ value = 1 }),
  State({ value = 'idle' })
)

local cameraLeft = -2.5 * tile_size_x
local cameraTop = -2 * tile_size_y
local cameraWidth = 7.5 * tile_size_x
local cameraHeight = 19 * tile_size_y
World.entity(
  { name = "Camera" },
  Follower({
    following = playerEntity,
    within = {
      x1 = 4, offset_x = -9.5, x2 = 24.3,
      y1 = -5, offset_y = -5.125, y2 = 33
    }
  }),
  Position({ x = 0, y = 0 }),
  Box({ x = cameraLeft, y = cameraTop, w = cameraWidth, h = cameraHeight }),
  Rectangle({ border_color = 12 })
)
-- loot (Position, Sprite/Drawable?, Container, Owner/Contained?, Health)
-- tile ? (Position, Sprite/Drawable?, Container, Owner/Contained?)
-- bullet (Position, Health?, Animation, Physics, Sprite/Drawable?, Owner/Contained?, Power)
-- explosion (Position, Health?, Animation, Sprite/Drawable?)
-- monsters (Position, Physics, Animation, Health, Box/Size, Sprite/Drawable?, Container, Ai, Shoot, Capture?, Control?)
-- exit? (Position, Animation, Sprite/Drawable?)
-- particle (Position, Physics, Particle, Health, Color, Sprite/Drawable)
-- float (Position, Color, Label)