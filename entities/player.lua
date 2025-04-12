local machine = require("statemachine")

local playerWidth, playerHeight = 15, 15
local playerEntity = World.entity(
  {},
  Animation({
    offset_x = 0,
    offset_y = 0,
    start_offset_x = 0,
    start_offset_y = 0,
    offset_t = 0,
    sprites = {1, 2, 3, 4},
  }),
  Box({x = 0, y = 0, w = playerWidth, h = playerHeight}),
  Capture({time = 0, power = 1}),
  Control(),
  InGrid(),
  Physics({xv = 0, yv = 0, speed = 0.06, dir = vec(0,0)}),
  Player({number = 1}),
  Position({ x = 9, y = 9 }), -- TODO: set this for each level
  Shoot({time = 0, dir = nil, speed = 6, rate = 60, bullets = {}}),
  Sprite({number = 1}),
  State({
    machine = machine.create({
      initial = "idle",
      events = {
        { name = "move", 					 from = {"idle", "hovering"}, to = "moving" },
        { name = "stop_moving", 	 from = "moving", 						to = "hovering" },
        { name = "land", 					 from = "hovering",						to = "idle" },
        { name = "capture",  			 from = {"idle", "hovering"},	to = "capturing" },
        { name = "stop_capturing", from = "capturing",				  to = "idle" },
        { name = "shoot",          from = {"idle", "hovering"}, to = "shooting" },
        { name = "stop_shooting",  from = {"shooting"},         to = "idle" }
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
          entity[Capture].time = 0
          sfx(-1, 8)
        end,
        onentershooting = function(self, event, from, to, entity)
          entity[Shoot].time = entity[Shoot].rate
          sfx(Sounds.shooting, 8)
        end,
        onafterstop_shooting = function(self, event, from, to)
          sfx(-1, 7)
        end
      }
    })
  })
)

return playerEntity