local updateActorState = tiny.processingSystem()

updateActorState.filter = tiny.requireAll('isActor')
local log               = require('log')

function updateActorState:process(entity, _dt)
	local dir = entity.physics.dir
	if not dir then return end
	local state = entity.state
	local fsm = state.machine
	local event
	if     dir.x == 0.0 and dir.y == 0.0 then event = state.dirToState.neutral
	elseif dir.x == -1  and dir.y == 0.0 then event = state.dirToState.left
	elseif dir.x == 1   and dir.y == 0.0 then event = state.dirToState.right
	elseif dir.y == -1  and dir.x == 0.0 then event = state.dirToState.up
	elseif dir.y == 1   and dir.x == 0.0 then event = state.dirToState.down end

	log.info('actor:'..pod(entity.position))
	log.info('event:'..pod(event))

	fsm[event](fsm)
end

return updateActorState