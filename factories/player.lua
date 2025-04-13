local machine = require("statemachine")
local class = require 'lowerclass'
Timer = require("timer")

Player = class('player')

local playerWidth, playerHeight = 15, 15

local player_sounds = {
  start_engine = 48,
  stop_engine = 49,
  start_capturing = 50,
  captured = 51,
  shooting = 52
}

local can_play_start_engine = true

local onentermoving = function(self, event, from, to)
  if not can_play_start_engine then return end
  hover_t = nil
  sfx(player_sounds.start_engine, 7)
  can_play_start_engine = false
end

local captureStates = {
  "capturing",
  "capturing2",
  "capturing3",
}

local movingStates = {
  "moving_left",
  "moving_right",
  "moving_up",
  "moving_down"
}

local idleStates = {
  "idle",
  "hovering"
}

local movingAndIdleStates = ShallowMerge(movingStates, idleStates)

function Player:makeEntity(number, name)
  return World.entity(
    {},
    Actor({
      type = "player",
      id = number,
      name = name
    }),
    Animation({
      offset_x = 0,
      offset_y = 0,
      start_offset_x = 0,
      start_offset_y = 0,
      offset_t = 0,
      statesToSprites = {
        idle = 0,
        moving_left = 1,
        moving_right = 2,
        moving_up = 3,
        moving_down = 4,
        capturing = 5,
        capturing2 = 6,
        capturing3 = 7,
        hovering = 8,
        shooting = 9 -- TODO: add muzzle flash with direction
      }
    }),
    Box({x = 0, y = 0, w = playerWidth, h = playerHeight}),
    Capture({time = 0, power = 1}),
    Control(),
    Hover(),
    Physics({xv = 0, yv = 0, speed = 0.06, dir = vec(0,0)}),
    Position({ x = 9, y = 9 }), -- TODO: set this for each level
    Shoot({time = 0, dir = nil, speed = 6, rate = 60, bullets = {}}),
    Sound(player_sounds),
    Sprite({number = 0}),
    State({
      dirToState = {
        left =    "move_left",
        right =   "move_right",
        up =      "move_up",
        down =    "move_down",
        neutral = "stop_moving"
      },
      machine = machine.create({
        initial = "idle",
        events = {
          { name = "move_left", 		 from = movingAndIdleStates, to = "moving_left" },
          { name = "move_right", 		 from = movingAndIdleStates, to = "moving_right" },
          { name = "move_up", 		   from = movingAndIdleStates, to = "moving_up" },
          { name = "move_down", 		 from = movingAndIdleStates, to = "moving_down" },
          { name = "stop_moving", 	 from = movingStates, 				                             to = "hovering" },
          { name = "land", 					 from = "hovering",						                             to = "idle" },
          { name = "capture",  			 from = {"idle", "hovering"},	                             to = "capturing" },
          { name = "capture2",  		 from = "capturing",	                                     to = "capturing2" },
          { name = "capture3",  		 from = "capturing2",       	                             to = "capturing3" },
          { name = "stop_capturing", from = captureStates,			                               to = "idle" },
          { name = "shoot",          from = {"idle", "hovering"},                              to = "shooting" },
          { name = "stop_shooting",  from = {"shooting"},                                      to = "idle" }
        },
        callbacks = {
          onentermoving_left =  onentermoving,
          onentermoving_right = onentermoving,
          onentermoving_up =    onentermoving,
          onentermoving_down =  onentermoving,
          onafterland = function(self, event, from, to)
            sfx(player_sounds.stop_engine, 7)
          end,
          onenterhovering = function(self, event, from, to)
            can_play_start_engine = true
            HoverTimer:after(0.5, function() self:land() end)
          end,
          onaftercapture = function (self, event, from, to)
            sfx(player_sounds.start_capturing, 8)
            sfx(-1, 7)
          end,
          onafterstop_capturing = function(self, event, from, to, entity)
            entity[Capture].time = 0
            sfx(-1, 8)
          end,
          onentershooting = function(self, event, from, to, shoot_component)
            sfx(player_sounds.shooting, 8)
            shoot_component.time = shoot_component.rate
          end,
          onafterstop_shooting = function(self, event, from, to)
            sfx(-1, 7)
          end
        }
      })
    })
  )
end