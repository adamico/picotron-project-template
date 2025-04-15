local shooting = ecs.processingSystem()
local Bullet = require('bullet')

shooting.filter = ecs.requireAll('shoot')

function shooting:process(entity, _dt)
  local position = entity.position
  local shoot = entity.shoot
  local state = entity.state

  local fsm = state.machine
  local bullets = shoot.bullets
  local shooting_rate = shoot.rate

  if btn(5) and shoot.time == 0 then
    shoot.dir = ButtonsToDir()
    if shoot.dir.x ~= 0 or shoot.dir.y ~=0 then
      fsm:shoot(shoot)
    end
  else
    fsm:stop_shooting()
  end

  if shoot.time == shooting_rate then
    local bullet = Bullet:new(position, shoot, entity)
    world:add(bullet)
    add(bullets, bullet)
  end
  shoot.time = max(shoot.time - 1, 0)
end

return shooting