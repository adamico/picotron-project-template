local outOfMapBounds = function(position, bounds)
  return position.x/TileSizeX > bounds.x - 10
    or position.y/TileSizeY > bounds.y
    or position.x < 0 or position.y < 0
end

systems.killBullets = World.system({Bullet, Physics, Position}, function(bullet)
  local position = bullet[Position]
  local owner = bullet[BelongsTo]
  local map_bounds = {
    x = Map:width(),
    y = Map:height()
  }

  if outOfMapBounds(position, map_bounds) then
    World.remove(bullet)
    del(owner[Shoot].bullets, bullet)
  end
end)