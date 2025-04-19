local machine = require('statemachine')
local log     = require('log')
local astar   = require('astar')

local Enemy = class('enemy')

local movingStates = {'moving'}
local idleStates   = {'idle'}

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
  self.belongsTo   = nil
  self.box         = {x = 0, y = 0, w = w, h = h}
  self.damage      = 10
  self.destination = {
    path  = nil,
    step  = nil,
    goal = nil
  }
  self.health      = 10
  self.isActor     = true
  self.isEnemy     = true
  self.isFlashing  = false
  self.maxHealth   = 10
  self.number      = 5
  self.physics     = {vel=vec(0,0), dir=vec(0,0)}
  self.position    = position
  self.sprite      = 18
  self.state       = {
    dirToState = {
      neutral = 'stop_moving',
      left =    'move',
      right =   'move',
      up =      'move',
      down =    'move'
    },
    machine = machine.create({
      initial = 'idle',
      events = {
        { name = 'move', 		    from = idleStates,   to = 'moving' },
        { name = 'stop_moving', from = movingStates, to = 'idle' }
      }
    })
  }
  self.task = self.think
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

local function randomDest(origin)
  local dest = rnd(1)<0.2 and origin + vec(flr(rnd(1)+1), flr(rnd(1)+1)) or vec(flr(rnd(origin.x+2)), flr(rnd(origin.y+2)))
  return dest
end

local function canHunt(player)
  return player.isCapturing()
  -- return (LineOfSight(self, player) or player.isCapturing())
    and not (player.isProtected or player.isInvincible)
end

function Enemy:getNearestPlayer()
  return players[1]
end

function Enemy:setPath()
  local start = vec(self.position.x, self.position.y)
  local goal = self.destination.goal
  local path = astar.getPath(start, goal, CanMoveTo)
  deli(path, 1)
  self.destination.path = path
end

function Enemy:setDir()
  local position = self.position
  local path = self.destination.path

  if not path or #path == 0 then return end
  local next_position = path[1]
  local new_dir = vec(
    next_position.x - position.x,
    next_position.y - position.y
  )
  self.physics.dir = new_dir
end

function Enemy:wander()
  -- AddDebug('task', 'wander')
  local player = players[1]
  if canHunt(player) then self.task = self.attack return end
  local path = self.destination.path
  local origin = self.belongsTo.position
  self.destination.goal = path and self.destination.goal or randomDest(origin)
  self:setPath()
  if not path or #path == 0 then self.task = self.think return end
  deli(path, 1)
  self:setDir()
end

function Enemy:attack()
  -- AddDebug('task', 'attack')
  local player = players[1]
  -- if not canHunt(player) then self.task = self.think return end
  local path = self.destination.path
  self.destination.goal = path and self.destination.goal or player.position
  self:setPath()
  if not path or #path == 0 then self.task = self.think return end
  deli(path, 1)
  self:setDir()
end

function Enemy:think(dt)
  -- AddDebug('task', 'think')
  local player = players[1]
  self.destination.path = nil
  self.physics.dir = vec(0,0)
  Timer.after(2, function()
    self.task = canHunt(player) and self.attack or self.wander
  end)
end

return Enemy