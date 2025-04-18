local executeAI = tiny.processingSystem(class('ExecuteAI'))
local Timer = require('timer')

executeAI.filter = tiny.requireAll('task')

function executeAI:process(entity, dt)
  entity:task(dt)
end

return executeAI