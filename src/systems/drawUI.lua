local pgui = require("pgui")

drawUI.isDrawSystem = true

systems.drawUI = World.system({Score}, function(entity)
	local score = entity[Score]

	local contents = {}
	add(contents, {"text", {text="Captured: "..pod(score.captured).."/x", size=vec(100,6)}})
	pgui:component("vstack", {pos=vec(365,5), contents=contents})
end)