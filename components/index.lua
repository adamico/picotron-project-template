Position = World.component({ x = 0, y = 0, angle = 0 })

Box = World.component()

Physics = World.component({
	xv = 0, yv = 0,
})

Follower = World.component({
	following = nil,
	within = nil
})

Player = World.component()
Bullet = World.component()
State = World.component()
Sprite = World.component()

Animation = World.component()

Bullets = World.component({list = {}})

BelongsTo = World.component()
Capture = World.component()

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