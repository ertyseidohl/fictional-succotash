class = require 'lib/middleclass'

local Field = require 'field'
local Ship = require 'ship'

-- globals
WIDTH = 800
HEIGHT = 600
MAXRADIUS = math.min(WIDTH, HEIGHT) * 0.75
field = Field:new(4, 32, MAXRADIUS)

local things = {
	field,
	Ship:new(1, {255,0,0,255}, 0),
	Ship:new(2, {0,0,255,255}, math.pi),
	Ship:new(3, {0,255,0,255}, math.pi * 0.5),
	Ship:new(4, {255,255,0,255}, math.pi * 1.5)
}

function love.draw()
	--love.graphics.clear()
	for _, thing in pairs(things) do
		thing:draw(thing)
	end
end

function love.update()
	for _, thing in pairs(things) do
		thing:update(thing)
	end
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

