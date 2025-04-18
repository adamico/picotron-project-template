local pgui = require("pgui")

local drawDebug = function(player, spawner)
	local physics  = player.physics
	local position = player.position
	local gun 	 = player.gun
	local fsm      = player.state.machine
	local bullets  = gun.bullets
	local state    = fsm.current
	local dir      = physics.dir

	local contents = {}
	add(contents, {"text", {text="cpu:"..flr(stat(1)*100), size=vec(200,8)}})
	add(contents, {"text", {text="Px/y: "..pod(position.x).."/"..pod(position.y)}})
	add(contents, {"text", {text="dirx/y: "..pod(dir.x).."/"..pod(dir.y)}})
	-- add(contents, {"text", {text="State: "..pod(state)}})
	-- add(contents, {"text", {text="Blink: "..pod(player.blink)}})
	-- add(contents, {"text", {text="Blink: "..pod(player.blink)}})
	add(contents, {"text", {text="Enemies: "..pod(#spawner.spawnedEnemies)}})
	local destination = spawner.spawnedEnemies[1].destination
	if destionation then add(contents, {"text", {text="Enemy task: "..pod(destination)}}) end

	-- add(contents, {"text", {text="animation offset t: "..pod(animation.offset_t)}})
	-- add(contents, {"text", {text="Sprite: "..pod(sprite.number)}})
	-- add(contents, {"text", {text="Shooting time: "..pod(gun.time)}})
	-- add(contents, {"text", {text="Shooting rate: "..pod(gun.rate)}})
	-- add(contents, {"text", {text="Shooting dir: "..pod(gun.dir)}})
	-- if bullets then
	-- 	add(contents, {"text", {text="bullets#"..pod(#bullets)}})
	-- 	if bullets[1] then 
	-- 		add(contents, {"text", {text="bullet sprite "..pod(bullets[1].sprite)}})
	-- 		add(contents, {"text", {text="bullet position "..pod(bullets[1].position)}})
	-- 	end
	-- end
	-- add(contents, {"text", {text="Capturing time: "..pod(capture.time)}})
	-- if Enemies and #Enemies > 0 then
	-- 	add(contents, {"text", {text="Enemypos1 "..pod(Enemies[1][Position])}})
	-- 	add(contents, {"text", {text="Enemypos2 "..pod(Enemies[2][Position])}})
	-- 	add(contents, {"text", {text="Enemypos3 "..pod(Enemies[3][Position])}})
	-- end
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end

return drawDebug