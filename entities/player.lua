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
          sfx(Sounds.start_engine, 7)
        end,
        onafterland = function(self, event, from, to)
          sfx(Sounds.stop_engine, 7)
        end,
        onenterhovering = function(self, event, from, to)
          hover_t = 0
        end,
        onaftercapture = function (self, event, from, to)
          sfx(Sounds.start_capturing, 8)
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

return playerEntity