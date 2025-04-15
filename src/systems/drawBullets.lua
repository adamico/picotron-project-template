local drawBullets = ecs.processingSystem()

drawBullets.isDrawSystem = true
drawBullets.filter = ecs.requireAll('bullet')

function drawBullets:process(entity, dt)
  entity:draw(dt)
end

return drawBullets