local pgui = require('pgui')
local drawUI = tiny.processingSystem()

drawUI.isDrawSystem = true

drawUI.filter = tiny.requireAll('isPlayer')

function drawUI:process(entity, _dt)
	local score = entity.score
	local health = entity.health
	local lives = entity.lives
	local maxHealth = entity.maxHealth

	local contents = {}
	add(contents, {'text', {text='Health: '..pod(health)..'/'..pod(maxHealth), size=vec(100,6)}})
	add(contents, {'text', {text='Lives: '..pod(lives)}})
	add(contents, {'text', {text='Captured: '..pod(score.captured)..'/x'}})
	pgui:component('vstack', {pos=vec(365,5), contents=contents})
end

return drawUI