local pgui = require("pgui")
local player

systems.drawDebug = World.system({Position, Player, Physics, Animation}, function(entity)
	local player = entity[Player]
	local position = entity[Position]
	local contents = {}
	add(contents, {"text", {text="cpu:"..flr(stat(1)*100), size=vec(100,8)}})
	-- add(contents, {"text", {text="Px/y: "..pod(position.x).."/"..pod(position.y)}})
	-- add(contents, {"text", {text="State: "..pod(player_fsm.current)}})
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end)