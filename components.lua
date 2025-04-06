-- components
Position = World.component({ x = 0, y = 0 })
Box = World.component()
Player = World.component({
	moving = false,
	capturing = false,
	capture_time = 0,
	number = 0
})

Follower = World.component({ following = nil, within = nil })
Speed = World.component()
Sprite = World.component()
Animation = World.component()
Rectangle = World.component({ border_color = 0 })