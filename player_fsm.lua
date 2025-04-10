local machine = require("statemachine")

player_fsm = machine.create({
	initial = 'idle',
	events = {
		{ name = 'move', 					 	 from = {'idle', 'hovering'}, to = 'moving' },
		{ name = 'stop_moving', 	 	 from = 'moving', 						to = 'hovering' },
		{ name = 'land', 					 	 from = 'hovering',						to = 'idle' },
		{ name = 'capture',  			 	 from = {'idle', 'hovering'},	to = 'capturing' },
		{ name = 'stop_capturing', 	 from = 'capturing',				  to = 'idle' }
	},
	callbacks = {
		onentermoving = function(self, event, from, to)
			hover_t = nil
			sfx(sounds.start_engine, 7)
		end,
		onafterland = function(self, event, from, to)
			sfx(sounds.stop_engine, 7)
		end,
		onenterhovering = function(self, event, from, to)
			hover_t = 0
		end,
		onaftercapture = function (self, event, from, to)
			sfx(sounds.start_capturing, 8)
			sfx(-1, 7)
		end,
		onafterstop_capturing = function(self, event, from, to, entity)
			entity.capture_time = 0
			sfx(-1, 8)
		end
	}
})

return player_fsm