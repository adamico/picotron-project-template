local drawBullets = ecs.processingSystem(class('DrawBullets'))

drawBullets.isDrawSystem = true
drawBullets.filter = ecs.requireAll('bullet')

function drawBullets:process(entity, dt)
  entity:draw(dt)
end

return drawBullets