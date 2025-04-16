local pgui = require('pgui')
local drawUI = ecs.processingSystem()

drawUI.isDrawSystem = true

drawUI.filter = ecs.requireAll('score')

function drawUI:process(entity, _dt)
	local score = entity.score

	local contents = {}
	add(contents, {'text', {text='Captured: '..pod(score.captured)..'/x', size=vec(100,6)}})
	pgui:component('vstack', {pos=vec(365,5), contents=contents})
end

return drawUI