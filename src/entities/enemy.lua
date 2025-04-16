local machine = require("statemachine")

local Enemy = class('enemy')

local movingStates = {"moving"}
local idleStates   = {"idle"}

Enemy.isEnemy = true

function Enemy:initialize(position, w, h)
  self.actor = {
    type = "enemy",
  }
  self.animation = {
    offset_speed = 0.06,
    offset_x = 0,
    offset_y = 0,
    start_offset_x = 0,
    start_offset_y = 0,
    offset_t = 0,
    statesToSprites = {
      idle = 18,
      moving = 19
    }
  }
  self.box      = {x = 0, y = 0, w = w, h = h}
  self.physics  = {vel=vec(0,0), dir=vec(0,0)}
  self.position = position
  self.sprite   = 18
  self.state    = {
    dirToState = {
      neutral = "stop_moving",
      left =    "move",
      right =   "move",
      up =      "move",
      down =    "move"
    },
    machine = machine.create({
      initial = "idle",
      events = {
        { name = "move", 		    from = idleStates,   to = "moving" },
        { name = "stop_moving", from = movingStates, to = "idle" }
      }
    })
  }
  self.z_index = 3
end

function Enemy:draw(_dt)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x*TileSizeX, self.position.y*TileSizeY)
end

function Enemy:gotHit()
  sfx(EnemySounds.hit)
end

return Enemy