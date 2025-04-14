include("src/factories/bullet.lua")

systems.shoot = World.system({Shoot, Position}, function(entity)
  local position = entity[Position]
  local shoot = entity[Shoot]
  local state = entity[State]

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
    local bullet = BulletClass:new()
    local bulletEntity = bullet:makeEntity(position, shoot, entity)
    add(bullets, bulletEntity)
  end
  shoot.time = max(shoot.time - 1, 0)
end)