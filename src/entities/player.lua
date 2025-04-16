local machine = require('statemachine')

local Player = class('Player')

local can_play_start_engine = true
local onentermoving = function(self, event, from, to)
  if not can_play_start_engine then return end
  hover_t = nil
  sfx(PlayerSounds.start_engine, 7)
  can_play_start_engine = false
end

local captureStates = {
  'capturing',
  'capturing2',
  'capturing3',
}

local movingStates = {
  'moving_left',
  'moving_right',
  'moving_up',
  'moving_down'
}

local idleStates = {
  'idle',
  'hovering'
}

local movingAndIdleStates = ShallowMerge(movingStates, idleStates)

function Player:initialize(name, position)
  self.isPlayer = true
  self.isSolid = true

  self.actor = {
    type = 'player',
    id = number or 1,
    name = name or 'Player1'
  }

  self.animation = {
    offset_speed=0.06,
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
  }

  self.box      = {x=0, y=0, w=24, h=24}
  self.capture  = {time=0, power=1}
  self.control  = {}
  self.hover    = {}
  self.physics  = {vel=vec(0,0), dir=vec(0,0)}
  self.position = position or vec(0,0)
  self.score    = {captured=0 }
  self.shoot    = {time=0, dir=nil, speed=6, rate=60, bullets={}}
  self.sprite   = {number= 0}
  self.state    = {
    dirToState = {
      left =    'move_left',
      right =   'move_right',
      up =      'move_up',
      down =    'move_down',
      neutral = 'stop_moving'
    },
    machine = machine.create({
      initial = 'idle',
      events = {
        { name = 'move_left', 		 from = movingAndIdleStates, to = 'moving_left' },
        { name = 'move_right', 		 from = movingAndIdleStates, to = 'moving_right' },
        { name = 'move_up', 		   from = movingAndIdleStates, to = 'moving_up' },
        { name = 'move_down', 		 from = movingAndIdleStates, to = 'moving_down' },
        { name = 'stop_moving', 	 from = movingStates, 				                             to = 'hovering' },
        { name = 'land', 					 from = 'hovering',						                             to = 'idle' },
        { name = 'capture',  			 from = {'idle', 'hovering'},	                             to = 'capturing' },
        { name = 'capture2',  		 from = 'capturing',	                                     to = 'capturing2' },
        { name = 'capture3',  		 from = 'capturing2',       	                             to = 'capturing3' },
        { name = 'stop_capturing', from = captureStates,			                               to = 'idle' },
        { name = 'shoot',          from = {'idle', 'hovering'},                              to = 'shooting' },
        { name = 'stop_shooting',  from = {'shooting'},                                      to = 'idle' }
      },
      callbacks = {
        onentermoving_left =  onentermoving,
        onentermoving_right = onentermoving,
        onentermoving_up =    onentermoving,
        onentermoving_down =  onentermoving,
        onafterland = function(self, event, from, to)
          sfx(PlayerSounds.stop_engine, 7)
        end,
        onenterhovering = function(self, event, from, to)
          can_play_start_engine = true
          HoverTimer:after(0.5, function() self:land() end)
          -- TODO: restart the timer when moving again
        end,
        onaftercapture = function (self, event, from, to)
          sfx(PlayerSounds.start_capturing, 8)
          sfx(-1, 7)
        end,
        onafterstop_capturing = function(self, event, from, to, capture_component)
          capture_component.time = 0
          sfx(-1, 8)
        end,
        onentershooting = function(self, event, from, to, shoot_component)
          sfx(PlayerSounds.shooting, 8)
          shoot_component.time = shoot_component.rate
        end,
        onafterstop_shooting = function(self, event, from, to)
          sfx(-1, 7)
        end
      }
    })
  }
  self.z_index = 1000
end


local function drawOffset(sprite, position, offset)
  local offsetpos = {x=position.x*TileSizeX + offset.x, y=position.y*TileSizeY + offset.y}
  if (offsetpos.x ~= position.x*TileSizeX or offsetpos.y ~= position.y*TileSizeY) then
    for n in all{0,1,7,10,12,16,28} do
      pal(n,1)
    end
    palt(30, true)
    palt(0, false)
    spr(sprite, position.x*TileSizeX, position.y*TileSizeY)
    pal()
  end
end

function Player:draw()
	local animation = self.animation
	local position = self.position
	local state = self.state.machine.current

	local offset = {x=animation.offset_x, y=animation.offset_y}
  self.sprite = animation.statesToSprites[state]

  -- drawOffset(self.sprite, position, offset)

	palt(30, true)
	palt(0, false)
	spr(self.sprite,
		position.x * TileSizeX + offset.x,
		position.y * TileSizeY + offset.y)
end

function Player:onHit()
  sfx(PlayerSounds.hit)
end

function Player:onCollision(collision)
  if collision.other.isEnemy then self:onHit() end
  --TODO: check invuln and isAlive for player and enemy
end

return Player