systems.updateActorState = World.system({Actor, State}, function(entity)
	local dir = entity[Physics].dir
	local state = entity[State]
	local fsm = state.machine
	local stateChange
	if     dir.x == 0.0 and dir.y == 0.0 then stateChange = state.dirToState.neutral
	elseif dir.x == -1  and dir.y == 0.0   then stateChange = state.dirToState.left
	elseif dir.x == 1   and dir.y == 0.0   then stateChange = state.dirToState.right
	elseif dir.y == -1  and dir.x == 0.0   then stateChange = state.dirToState.up
	elseif dir.y == 1   and dir.x == 0.0  then stateChange = state.dirToState.down end
	return fsm[stateChange](fsm)
end)