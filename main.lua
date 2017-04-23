class = require 'lib/middleclass'

local Field = require 'field'
local Ship = require 'ship'
local MusicSystem = require 'musicsystem'

-- globals
WIDTH = 800
HEIGHT = 600
MAXRADIUS = math.min(WIDTH, HEIGHT) * 0.75
field = Field:new(4, 32, MAXRADIUS)
BPM = 150
BPS = BPM / 60

local radialWidthHalf = (math.pi * 2 / 32) / 2

local things = {
	field,
	Ship:new(1, {255,0,0,255}, radialWidthHalf, {cc = 'z', c = 'x'}),
	Ship:new(2, {0,0,255,255}, math.pi + radialWidthHalf, {cc = 'c', c = 'v'}),
	Ship:new(3, {0,255,0,255}, math.pi * 0.5 + radialWidthHalf, {cc = 'b', c = 'n'}),
	Ship:new(4, {255,255,0,255}, math.pi * 1.5 + radialWidthHalf, {cc = 'm', c = ','})
}

local clock = {
	quarter_count = -1,
	half_count = -1,
	eigth_count = -1,
	time = 0,
}

local firstUpdate = true

local musicsystem = nil

--debug
debug_print_keypresses = false

function love.draw()
	--love.graphics.clear()
	for _, thing in pairs(things) do
		thing:draw(clock)
	end
end

function love.load() 
	musicsystem = MusicSystem:new()
end	

function love.update(dt)

	if firstUpdate then
		musicsystem:play()
		firstUpdate = false
	end

	--local nextClockTime = clock.time + dt
	local nextClockTime = musicsystem:update(dt)
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

	for _, thing in pairs(things) do
		thing:update(dt, clock)
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

	if key == "p" then
		musicsystem:adjustUp()
	elseif key == "o" then
		musicsystem:adjustDown()
	end
	io.flush()
end
