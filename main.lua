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
	Ship:new(1, 'red', 0),
	Ship:new(2, 'blue', 180),
	Ship:new(3, 'green', 90),
	Ship:new(4, 'yellow', 270)
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

