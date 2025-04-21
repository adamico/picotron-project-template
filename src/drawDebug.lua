local pgui = require("pgui")


local drawDebug = function()
	local contents = {}

	for label, value in pairs(Debug) do
		add(contents, {"text", {text=label..":"..value, size=vec(200,8)}})
	end
	pgui:component("vstack", {pos=vec(5,5), contents=contents})
end

return drawDebug