systems.handleInput = World.system({Control}, function(entity)
	local dir = (not btn(4) and not btn(5)) and ButtonsToDir() or vec(0,0)
	entity[Physics].dir = dir
end)