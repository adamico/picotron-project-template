local pgui = require("pgui")
local player

systems.drawDebug = World.system({Position, Player, Physics, Animation, Sprite}, function(entity)
	local player = entity[Player]
	local state = player.state.current
	local position = entity[Position]
	local sprite = entity[Sprite]
	local contents = {}
	add(contents, {"text", {text="cpu:"..flr(stat(1)*100), size=vec(100,8)}})
	-- add(contents, {"text", {text="Px/y: "..pod(position.x).."/"..pod(position.y)}})
	add(contents, {"text", {text="Sprite: "..pod(sprite.number)}})
	add(contents, {"text", {text="State: "..pod(state)}})
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end)