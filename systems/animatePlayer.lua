local isBetween = function(n, a, b)
	return n >= a and n < b
end

local stateForCapture = function(capture_time)
	local state
	if isBetween(capture_time, 0, 33) then state = "capturing"
	elseif isBetween(capture_time, 33, 66) then state = "capturing2"
	elseif isBetween(capture_time, 66, 100) then state = "capturing3"
	else
		state = "idle"
	end

	return state
end

local stateForDir = function(dir)
	local state
	if dir.x == -1 then state = "m_left" end
	if dir.x == 1  then state = "m_right" end
	if dir.y == -1 then state = "m_up" end
	if dir.y == 1  then state = "m_down" end

	return state
end

systems.animatePlayer = World.system({Player, Sprite, Animation}, function(entity)
	-- local animation = entity[Animation]
	local sprite = entity[Sprite]
	local capture_time = entity[Capture].time
	local state = entity[State].machine.current
	local spriteNumbersForStates = {
		idle = 0,
		m_left = 1,
		m_right = 2,
		m_up = 3,
		m_down = 4,
		hovering = 8,
		capturing = 5,
		capturing2 = 6,
		capturing3 = 7,
		shooting = 9 -- TODO: add muzzle flash with direction
	}

	local new_sprite_value
	if state == 'moving' then
		new_sprite_value = spriteNumbersForStates[stateForDir(entity[Physics].dir)]
	elseif state == 'capturing' then
		new_sprite_value = spriteNumbersForStates[stateForCapture(capture_time)]
	else
		new_sprite_value = spriteNumbersForStates[state]
	end

	sprite.number = new_sprite_value --TODO: readd player movement animation
	-- local sprites = animation.sprites
	-- local sprite_index = flr((t()*6)%4+1)
	-- sprite.number = sprites[sprite_index]
end)