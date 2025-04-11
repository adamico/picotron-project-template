local outOfMapBounds = function(pos)

end

systems.killBullets = World.system({Bullet, Physics, Position}, function(bullet)
  local position = bullet[Position]
  local owner = bullet[BelongsTo]
  local map_bounds = {
    x = Map:width(),
    y = Map:height()
  }

  if flr(position.x/TileSizeX) > map_bounds.x - 10 or position.y/TileSizeY > map_bounds.y then
    World.remove(bullet)
    del(owner[Bullets].list, bullet)
  end
end)