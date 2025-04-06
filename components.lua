Position = World.component({ x = 0, y = 0, angle = 0 })
Box = World.component()
Physics = World.component({
	xv = 0, yv = 0,
	-- speed power
})
Player = World.component({
	moving = false,
	capturing = false,
	capture_time = 0,
	number = 0,
	alive = true,
	protected = false
})

Follower = World.component({
	following = nil,
	within = {
		x1 = 1, offset_x = -12.5, x2 = 20.3,
		y1 = 0, offset_y = -7, y2 = 31
	}
})
Sprite = World.component()
Animation = World.component()
Rectangle = World.component({ border_color = 0 })

-- Capture (move some player attributes here, add power)
-- Shoot
-- Drawable (add a type and get rid of sprite?)
-- Container (inventory for power ups)
-- Owner/Contained (inverse of container?)
-- Score
-- Size (instead of box?)
-- Ai (for monsters)
-- Power (for loot)
-- Health
-- Form
-- Monster (kind)
-- Flash
-- Particle
-- Label