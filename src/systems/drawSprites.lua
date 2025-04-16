local drawSprites = tiny.sortedProcessingSystem()

drawSprites.isDrawSystem = true
drawSprites.filter = tiny.requireAll('sprite')

function drawSprites:process(entity, dt)
  entity:draw(dt)
end

function drawSprites:compare(e1, e2)
  return e1.z_index > e2.z_index
end

return drawSprites