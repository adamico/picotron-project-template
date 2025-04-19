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

	for label, value in pairs(Debug) do
		add(contents, {"text", {text=label..":"..value, size=vec(200,8)}})
	end
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end

return drawDebug