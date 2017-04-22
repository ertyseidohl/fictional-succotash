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

local bpm = 120
local bps = (bpm / 60)
local temp_clock = 0
local temp_beats = 0
local temp_eighths = 0

function love.draw()
	--love.graphics.clear()
	local clock = {
		beats = 4,
		beat = temp_beats % 4,
		eighths = temp_eighths % 4
	}

	for _, thing in pairs(things) do
		thing:draw(clock)
	end
end

function love.update(dt)

	temp_clock = temp_clock + dt
	temp_beats = math.floor(temp_clock * bps)
	temp_eighths = math.floor(temp_clock * bps * 8)

	for _, thing in pairs(things) do
		thing:update()
	end

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

