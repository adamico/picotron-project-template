local log = require "log"
local drawSprites = tiny.sortedProcessingSystem()

drawSprites.isDrawSystem = true
drawSprites.filter = tiny.requireAll('sprite')

local function getCellRect(world, cx, cy)
  local cellSize = world.cellSize
  local x, y = world:toWorld(cx, cy)
  return x, y, cellSize, cellSize
end

local function drawBump()
  for cy, row in pairs(bumpWorld.rows) do
    for cx, _cell in pairs(row) do
      local x, y, w, h = getCellRect(bumpWorld, cx, cy)
      rect(x, y, x+w, x+h, 8)
      log.info("x:"..x.."y:"..y)
    end
  end
end

function drawSprites:process(entity, dt)
  entity:draw(dt)
  -- drawBump()
end

function drawSprites:compare(e1, e2)
  return e1.z_index > e2.z_index
end

return drawSprites