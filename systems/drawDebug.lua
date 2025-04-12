local pgui = require("pgui")

systems.drawDebug = World.system({Position, Physics, Animation, Sprite}, function(entity)
	local state = entity[State].machine.current
	local position = entity[Position]
	local sprite = entity[Sprite]
	local physics = entity[Physics]
	local shoot = entity[Shoot]
	local bullets = entity[Shoot].bullets
	local contents = {}
	add(contents, {"text", {text="cpu:"..flr(stat(1)*100), size=vec(100,8)}})
	-- add(contents, {"text", {text="Px/y: "..pod(position.x).."/"..pod(position.y)}})
	add(contents, {"text", {text="Sprite: "..pod(sprite.number)}})
	add(contents, {"text", {text="State: "..pod(state)}})
	add(contents, {"text", {text="Shooting time: "..pod(shoot.time)}})
	add(contents, {"text", {text="Capturing time: "..pod(entity[Capture].time)}})
	-- add(contents, {"text", {text="Shooting dir: "..pod(shoot.dir)}})

	add(contents, {"text", {text="bullets#"..pod(#bullets)}})

	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end)