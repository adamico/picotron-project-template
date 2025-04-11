
local buttonsToDir = function()
	local dir = vec(0,0)

	if not btn(4) and not btn(5) then
		if btn(0) then
			dir.x = -1
			dir.y = 0
		elseif btn(1) then
			dir.x = 1
			dir.y = 0
		elseif btn(2) then
			dir.x = 0
			dir.y = -1
		elseif btn(3) then
			dir.x = 0
			dir.y = 1
		end
	end

	return dir
end

systems.handleInput = World.system({Player, Position}, function(entity)
	local physics = entity[Physics]
	physics.dir = buttonsToDir() --TODO: account for player number
end)