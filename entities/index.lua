local machine = require("statemachine")

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
  Player({
    number = 0,
    capture_time = 0,
    alive = true,
    protected = false,
    state = machine.create({
      initial = 'idle',
      events = {
        { name = 'move', 					 	 from = {'idle', 'hovering'}, to = 'moving' },
        { name = 'stop_moving', 	 	 from = 'moving', 						to = 'hovering' },
        { name = 'land', 					 	 from = 'hovering',						to = 'idle' },
        { name = 'capture',  			 	 from = {'idle', 'hovering'},	to = 'capturing' },
        { name = 'stop_capturing', 	 from = 'capturing',				  to = 'idle' }
      },
      callbacks = {
        onentermoving = function(self, event, from, to)
          hover_t = nil
          sfx(sounds.start_engine, 7)
        end,
        onafterland = function(self, event, from, to)
          sfx(sounds.stop_engine, 7)
        end,
        onenterhovering = function(self, event, from, to)
          hover_t = 0
        end,
        onaftercapture = function (self, event, from, to)
          sfx(sounds.start_capturing, 8)
          sfx(-1, 7)
        end,
        onafterstop_capturing = function(self, event, from, to, entity)
          entity.capture_time = 0
          sfx(-1, 8)
        end
      }
    })
  }),
  Physics({ xv = 0, yv = 0}),
  Position({ x = 9, y = 9 }), -- TODO: set this for each level
  Sprite({ number = 1 })
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
  Box({ x = cameraLeft, y = cameraTop, w = cameraWidth, h = cameraHeight })
)
-- loot (Position, Sprite/Drawable?, Container, Owner/Contained?, Health)
-- bullet (Position, Health?, Animation, Physics, Sprite/Drawable?, Owner/Contained?, Power)
-- explosion (Position, Health?, Animation, Sprite/Drawable?)
-- monsters (Position, Physics, Animation, Health, Box/Size, Sprite/Drawable?, Container, Ai, Shoot, Capture?, Control?)
-- exit? (Position, Animation, Sprite/Drawable?)
-- particle (Position, Physics, Particle, Health, Color, Sprite/Drawable)
-- float (Position, Color, Label)