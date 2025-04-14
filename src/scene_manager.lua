local class    = require('middleclass')
local Stateful = require('stateful')

SceneManager = class('SceneManager'):include(Stateful)

function SceneManager:initialize() end
function SceneManager:update() end
function SceneManager:draw() end

return SceneManager