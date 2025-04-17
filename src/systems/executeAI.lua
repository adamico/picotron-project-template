local executeAI = tiny.processingSystem(class('ExecuteAI'))

executeAI.filter = tiny.requireAll('ai')

function executeAI:initialize(target)
  self.target = target
end

function executeAI:process(entity, dt)
  if not self.target then return end

  entity:think(dt)
end

return executeAI