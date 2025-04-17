local updateActorState = tiny.processingSystem()

updateActorState.filter = tiny.requireAll('isActor')

function updateActorState:process(entity, _dt)
	local dir = entity.physics.dir
	local state = entity.state
	local fsm = state.machine
	local stateChange
	if     dir.x == 0.0 and dir.y == 0.0 then stateChange = state.dirToState.neutral
	elseif dir.x == -1  and dir.y == 0.0 then stateChange = state.dirToState.left
	elseif dir.x == 1   and dir.y == 0.0 then stateChange = state.dirToState.right
	elseif dir.y == -1  and dir.x == 0.0 then stateChange = state.dirToState.up
	elseif dir.y == 1   and dir.x == 0.0 then stateChange = state.dirToState.down end

	fsm[stateChange](fsm)
end

return updateActorState