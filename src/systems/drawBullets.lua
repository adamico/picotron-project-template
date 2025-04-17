local drawBullets = tiny.processingSystem()

drawBullets.isDrawSystem = true
drawBullets.filter = tiny.requireAll('isBullet')

function drawBullets:process(entity, dt)
  entity:draw(dt)
end

return drawBullets