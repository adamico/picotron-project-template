local killBullets = tiny.processingSystem()

local outOfMapBounds = function(position, bounds)
  return position.x/TileSizeX > bounds.x - 10
    or position.y/TileSizeY > bounds.y
    or position.x < 0 or position.y < 0
end

killBullets.filter = tiny.requireAll('bullet')

function killBullets:process(entity, _dt)
  local position = entity.position
  local owner = entity.belongsTo

  local map_bounds = {
    x = Map:width(),
    y = Map:height()
  }

  if outOfMapBounds(position, map_bounds) then
    world:removeEntity(entity)
    del(owner.shoot.bullets, entity)
  end
end

return killBullets