Animation = World.component()
Actor = World.component()
BelongsTo = World.component()
Box = World.component()
Bullet = World.component()
Capture = World.component()
Control = World.component()
Enemy = World.component()
Follower = World.component({following = nil, within = nil})
Hover = World.component()
Physics = World.component({xv = 0, yv = 0, dir = vec(0,0), speed = 0})
Player = World.component()
Position = World.component({x = 0, y = 0, angle = 0})
Shoot = World.component()
Sound = World.component()
Spawner = World.component()
Sprite = World.component()
State = World.component()

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