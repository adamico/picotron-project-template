local machine    = require('statemachine')
local log        = require('log')
local luafinding = require('luafinding')
local Vector     = require('vector')  

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
  self.task = self.wait
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

local function getDirFor(step)
  -- calculate vector to get from current pos to next step in path
  return vec(-1,0)
end

local function randomDest()
  return Vector(min(flr(rnd(Map:width())) + 9, Map:width()-9),
                min(flr(rnd(Map:height())) + 9, Map:height()-9))
end

local function sameVectors(vec1, vec2)
  return vec1.x == vec2.x and vec1.y == vec2.y
end

local function canHunt(player)
  return (LineOfSight(self, player) or player.isCapturing())
    and not (player.isProtected or player.isInvincible)
end

function Enemy:getNearestPlayer()
  return players[1]
end

function Enemy:setPath(goal)
  local vgoal = Vector(goal.x, goal.y)
  local vstart = Vector(self.position.x, self.position.y)
  local map = {}
  for x=1,Map:width() do
    map[x] = {}
    for y=1,Map:height() do
      map[x][y] = CanMoveTo(x,y)
    end
  end
  self.destination.path = luafinding(vstart, vgoal, map):GetPath()
  self.destination.goal = vgoal
  self.destination.step = 1
end

function Enemy:changeDirAndAdvanceStep()
  self.physics.dir = getDirFor(self.destination.path[self.destination.step])
  self.destination.step = self.destination.step + 1
end

function Enemy:wander()
  if not self.destination.path then
    self:setPath(randomDest())
    return
  end

  if canHunt(self:getNearestPlayer()) then
    self.task = self.attack
    return
  end

  if sameVectors(self.position, self.destination.goal) then
    self.task = self.wait
    return
  end

  self:changeDirAndAdvanceStep()
end

function Enemy:attack()
  local player = players[1]
  if sameVectors(self.destination.goal, player.position) then
    self.task = self.wait
    return
  end

  self:setPath(player.position)
  self:changeDirAndAdvanceStep()
end

function Enemy:wait()
  self.destination.path = nil
  self.destination.step = nil
  self.destination.goal = nil
  self.physics.dir = vec(0,0)
  -- add a timer here
  Timer.after(2, function() self.task = self.wander end)
end

return Enemy