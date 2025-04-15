local handleInput = ecs.processingSystem(class('HandleInput'))

handleInput.filter = ecs.requireAll('control')

function handleInput:process(entity, _dt)
	local dir = (not btn(4) and not btn(5)) and ButtonsToDir() or vec(0,0)
	entity.physics.dir = dir
end

return handleInput