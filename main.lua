class = require 'lib/middleclass'

-- globals
BPM = 150
BPS = BPM / 60
WIDTH = 800
HEIGHT = 600
MAXRADIUS = math.min(WIDTH, HEIGHT) * 0.8

local Field = require 'field'
local Ship = require 'ship'

-- global field
field = Field:new(16, 32, MAXRADIUS)


love.graphics.setLineJoin('bevel')

local clock = {
	quarter_count = -1,
	half_count = -1,
	eigth_count = -1,
	time = 0
}

--debug
debug_print_keypresses = false

function love.draw()
	field:draw(clock)
end

function love.update(dt)
	local nextClockTime = clock.time + dt
	local next_clock = {
		half_count = math.floor(nextClockTime * BPS / 2) % 2,
		quarter_count = math.floor(nextClockTime * BPS) % 4,
		eighth_count = math.floor(nextClockTime * BPS * 2) % 8,
		sixteenth_count = math.floor(nextClockTime * BPS * 4) % 16,
		time = nextClockTime
	}

	if next_clock['sixteenth_count'] ~= clock['sixteenth_count'] then
		next_clock['sixteenth_count'] = true;
	else
		next_clock['sixteenth_count'] = false;
	end

	if next_clock['eighth_count'] ~= clock['eighth_count'] then
		next_clock['is_on_eighth'] = true;
	else
		next_clock['is_on_eighth'] = false;
	end

	if next_clock['quarter_count'] ~= clock['quarter_count'] then
		next_clock['is_on_quarter'] = true;
	else
		next_clock['is_on_quarter'] = false;
	end

	if next_clock['half_count'] ~= clock['half_count'] then
		next_clock['is_on_half'] = true;
	else
		next_clock['is_on_half'] = false;
	end


	clock = next_clock

	field:update(dt, clock)

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
