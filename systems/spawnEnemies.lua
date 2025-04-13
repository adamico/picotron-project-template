local machine = require("statemachine")

systems.spawnEnemies = World.system({Spawner, Position}, function(entity)
  local position = entity[Position]

  while #Enemies < 3 do
    local width, height = 15, 15

    local movingStates = {"moving"}
    local idleStates = {"idle"}
    local enemy = World.entity(
      {},
      Actor({
        type = "enemy",
        id = 5
      }),
      Animation({
        offset_x = 0,
        offset_y = 0,
        start_offset_x = 0,
        start_offset_y = 0,
        offset_t = 0,
        statesToSprites = {
          idle = 18,
          moving = 19
        }
      }),
      Box({x = 0, y = 0, w = width, h = height}),
      Physics({xv = 0, yv = 0, speed = 0.06, dir = vec(0,0)}),
      Position({
        x = position.x + flr(rnd(3))+1,
        y = position.y + flr(rnd(3))+1
      }),
      Sprite({number = 18}),
      State({
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
      })
    )

    add(Enemies, enemy)
  end
end)