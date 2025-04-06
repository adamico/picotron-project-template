-- components
Position = World.component({ x = 0, y = 0 })
Box = World.component()
Physics = World.component({
	xv = 0, yv = 0
})
Player = World.component({
	moving = false,
	capturing = false,
	capture_time = 0,
	number = 0
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