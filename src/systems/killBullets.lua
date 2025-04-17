local killBullets = tiny.processingSystem()

local outOfMapBounds = function(position, bounds)
  return position.x/TileSizeX > bounds.x - 10
    or position.y/TileSizeY > bounds.y
    or position.x < 0 or position.y < 0
end

killBullets.filter = tiny.requireAll('isBullet')

function killBullets:process(entity, _dt)
  local map_bounds = {
    x = Map:width(),
    y = Map:height()
  }

  if outOfMapBounds(entity.position, map_bounds) then
    entity:die()
  end
end

return killBullets