local executeAI = tiny.processingSystem(class('ExecuteAI'))
local Timer = require('timer')
local log   = require('log')

executeAI.filter = tiny.requireAll('task')

function executeAI:process(entity, dt)
  local path = entity.destination.path
  local goal = entity.destination.goal
  local dir = entity.physics.dir

  -- if dir then AddDebug("endir", pod(dir)) end
  -- AddDebug("enpos", pod(vec(entity.position.x, entity.position.y)))
  -- if path then
  --   AddDebug("path", pod(path))
  --   AddDebug("next", pod(path[1]))
  --   AddDebug("goal", pod(goal))
  -- end

  entity:task(dt)
end

return executeAI