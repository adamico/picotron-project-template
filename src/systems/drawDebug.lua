local pgui = require("pgui")

systems.drawDebug = World.system({Position, Physics, Animation, Sprite, Shoot, Capture}, function(entity)
	local animation = entity[Animation]
	local capture = entity[Capture]
	local physics = entity[Physics]
	local position = entity[Position]
	local fsm = entity[State].machine
	local shoot = entity[Shoot]
	local sprite = entity[Sprite]

	local state = fsm.current
	local bullets = shoot.bullets
	local dir = physics.dir
	local contents = {}
	add(contents, {"text", {text="cpu:"..flr(stat(1)*100), size=vec(200,8)}})
	add(contents, {"text", {text="Px/y: "..pod(position.x).."/"..pod(position.y)}})
	add(contents, {"text", {text="dirx/y: "..pod(dir.x).."/"..pod(dir.y)}})
	add(contents, {"text", {text="State: "..pod(state)}})

	-- add(contents, {"text", {text="animation offset t: "..pod(animation.offset_t)}})
	-- add(contents, {"text", {text="Sprite: "..pod(sprite.number)}})
	-- add(contents, {"text", {text="Shooting time: "..pod(shoot.time)}})
	-- add(contents, {"text", {text="Shooting rate: "..pod(shoot.rate)}})
	-- add(contents, {"text", {text="Shooting dir: "..pod(shoot.dir)}})
	-- if bullets then
	-- 	add(contents, {"text", {text="bullets#"..pod(#bullets)}})
	-- end
	-- add(contents, {"text", {text="Capturing time: "..pod(capture.time)}})
	-- if Enemies and #Enemies > 0 then
	-- 	add(contents, {"text", {text="Enemypos1 "..pod(Enemies[1][Position])}})
	-- 	add(contents, {"text", {text="Enemypos2 "..pod(Enemies[2][Position])}})
	-- 	add(contents, {"text", {text="Enemypos3 "..pod(Enemies[3][Position])}})
	-- end
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end)