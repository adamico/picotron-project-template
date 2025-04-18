local log = require('log')

add_module_path("lib/beehive/")
local selector = require('selector')
local sequence = require('sequence')

local lineOfSightSystem = {
  canSeePlayer = function(self, entity,player)
    if not self.yup then
      self.yup = true
      return false
    end
    return true
  end,
}

-- Ask some other system if this entity can see the player.
local function canSeePlayer(entity, dt, player)
  -- log.info('canSeePlayer           called every frame!')
  -- if lineOfSightSystem:canSeePlayer(entity, player) then
    log.info('can see the player now!')
  --   return 'success'
  -- else
  --   log.info('cannot see player yet')
  --   return 'failure'
  -- end
  return 'failure'
end

-- Wait a bit of time before succeeding.
local function waitRandom(low, hi)
  local elapsed = 0
  local span = math.random(low, hi)

  return function(entity, dt)
    elapsed = elapsed + dt
    if elapsed >= span then
      elapsed = 0
      span = math.random(low, hi)
      return 'success'
    end
    return 'running'
  end
end

local function wander(entity, dt, player)
  return 'success'
end

local function chase(entity, dt, player)
  log.info('chase')
  -- Makes entity move towards player, then always returns 'success'.
  entity.physics.dir = vec(-1,0)
  return 'success'
end

local function walkAround()
  return sequence({
    wander,
    waitRandom(1, 3)
  })
end

-- If the player is visible, then chase them.
local function hunt()
  log.info('hunting')
  return sequence({
    canSeePlayer,
    chase
  })
end

-- Mostly spend your time walking around. If the player pops
-- up, hunt them.
function behavior()
  log.info('starting behavior 1')
  return selector({
    chase(),
    walkAround()
  })
end