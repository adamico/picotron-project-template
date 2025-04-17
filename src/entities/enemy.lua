local machine = require("statemachine")

local Enemy = class('enemy')

local movingStates = {"moving"}
local idleStates   = {"idle"}

function Enemy:initialize(position, w, h)
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
  self.belongsTo  = nil
  self.box        = {x = 0, y = 0, w = w, h = h}
  self.damage     = 10
  self.health     = 10
  self.isActor    = true
  self.isEnemy    = true
  self.isFlashing = false
  self.maxHealth  = 10
  self.number     = 5
  self.physics    = {vel=vec(0,0), dir=vec(0,0)}
  self.position   = position
  self.sprite     = 18
  self.state      = {
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
  FlashTo(self.isFlashing, {7, 32}, 8)
  palt(30, true)
  palt(0, false)
  spr(self.sprite, self.position.x*TileSizeX, self.position.y*TileSizeY)
  pal()
end

function Enemy:die()
  local spawner = self.belongsTo
  world:remove(self)
  del(spawner.spawnedEnemies, self)
end

function Enemy:takeDamage(damage)
  self.health = self.health - damage
  if self.health <= 0 then
    sfx(EnemySounds.die)
    self:die()
  else
    sfx(EnemySounds.hit)
  end
end

function Enemy:onHit(damage)
  self:takeDamage(damage)

  Timer.during(0.05, function() self.isFlashing = true end, function() self.isFlashing = false end)
end

return Enemy