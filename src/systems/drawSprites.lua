local drawSprites = ecs.processingSystem(class('DrawSprites'))

drawSprites.isDrawSystem = true
drawSprites.filter = ecs.requireAll('sprite')

function drawSprites:process(entity, dt)
  entity:draw(dt)
end

return drawSprites