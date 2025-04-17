local shooting = tiny.processingSystem()
local Bullet = require('bullet')

shooting.filter = tiny.requireAll('gun')

function shooting:process(entity, _dt)
  local position = entity.position
  local gun = entity.gun
  local state = entity.state

  local fsm = state.machine
  local shooting_rate = gun.rate

  if btn(5) and gun.time == 0 then
    gun.dir = ButtonsToDir()
    if gun.dir.x ~= 0 or gun.dir.y ~=0 then
      fsm:shoot(gun)
    end
  else
    fsm:stop_shooting()
  end

  if gun.time == shooting_rate then
    local bullet = Bullet:new(position, gun, entity)
    world:add(bullet)
  end
  gun.time = max(gun.time - 1, 0)
end

return shooting