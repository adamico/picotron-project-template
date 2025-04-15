local drawSprites = ecs.sortedProcessingSystem()

drawSprites.isDrawSystem = true
drawSprites.filter = ecs.requireAll('sprite')

function drawSprites:process(entity, dt)
  entity:draw(dt)
end

function drawSprites:compare(e1, e2)
  return e1.z_index > e2.z_index
end

return drawSprites