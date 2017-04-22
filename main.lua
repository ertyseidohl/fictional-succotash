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

local bpm = 120
local bps = (bpm / 60)
local temp_clock = 0
local temp_beats = 0
local temp_eighths = 0

--debug
debug_print_keypresses = false

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

	--debug
	if love.keyboard.isDown('p') then
		debug_print_keypresses = true
	end
end

-- debug
function love.keypressed(key)
	if debug_print_keypresses then
		print(key)
	end
end
