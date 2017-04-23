class = require 'lib/middleclass'

-- global settings
BPM = 300
BPS = BPM / 60
WIDTH = 1366
HEIGHT = 768
MAXRADIUS = math.min(WIDTH, HEIGHT) * 0.8
INNER_RINGS = 3
PLAYER_COLORS = {
	{255,0,0,255},
	{0,0,255,255},
	{0,255,0,255},
	{255,255,0,255}
}

DEVIL_RADIUS = 20
DEVIL_LINE_SEGMENTS = 20
DEVIL_COLOR = {127, 0, 127, 255}
GAME_OVER_DEVIL_GROWTH_SPEED = 10

HAND_BUFFER = 0
HAND_HEIGHT = 15
HAND_RADIAL_WIDTH = math.rad(10)

GAME_OVER_COUNTDOWN_MAX = 10

-- states
local STATE_MENU = 0
local STATE_PLAYING = 1
local STATE_GAME_OVER = 2

local Field = require 'field'
local MusicSystem = require 'musicsystem'
local Menu = require 'menu'

-- local vars
local gameState = STATE_MENU
local screenCapCanvas = love.graphics.newCanvas(WIDTH, HEIGHT)
local gameOverDevilSize = 0
local gameOverCountdown = GAME_OVER_COUNTDOWN_MAX

-- global objects
field = Field:new(16, 32, MAXRADIUS)
menu = Menu:new()

love.window.setMode(WIDTH, HEIGHT, {
	fullscreen = true,
	vsync = true,
	fullscreentype = "exclusive"
})
love.mouse.setVisible( false )
love.graphics.setLineJoin('bevel')

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
	if gameState == STATE_PLAYING then
		field:draw(clock)
	elseif gameState == STATE_MENU then
		menu:draw(clock)
	elseif gameState == STATE_GAME_OVER then
		love.graphics.setColor({255, 255, 255, 255})
		love.graphics.draw(screenCapCanvas)
		love.graphics.setColor(DEVIL_COLOR)
		love.graphics.circle('fill', WIDTH / 2, HEIGHT / 2, gameOverDevilSize)
		love.graphics.setColor({255,255,255,255})
		love.graphics.print(gameOverCountdown, WIDTH / 2, HEIGHT / 2)
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
		next_clock['is_on_sixteenth'] = true;
	else
		next_clock['is_on_sixteenth'] = false;
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

	if gameState == STATE_PLAYING then
		field:update(dt, clock)
	elseif gameState == STATE_MENU then
		menu:update(dt, clock)
	else
		if gameOverDevilSize < math.max(WIDTH, HEIGHT) then
			gameOverDevilSize = gameOverDevilSize + GAME_OVER_DEVIL_GROWTH_SPEED
		end

		if clock.is_on_half then
			gameOverCountdown = gameOverCountdown - 1
		end

		if gameOverCountdown == 0 then
			field:clear()
			gameOverCountdown = GAME_OVER_COUNTDOWN_MAX
			gameState = STATE_MENU
			gameOverDevilSize = 0
		end
	end

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	--debug
	if love.keyboard.isDown('p') then
		debug_print_keypresses = true
	end
end

function startGame()
	gameState = STATE_PLAYING
	field:buildShips(menu.players)
	menu:clearPlayers()
end

function endGame()
	love.graphics.setCanvas(screenCapCanvas)
		love.graphics.clear()
		field:draw(clock)
	love.graphics.setCanvas()
	gameState = STATE_GAME_OVER
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

	if key == "i" then
		menu:addCredit()
	end

	if key == "1" then
		menu:addPlayer(1)
	elseif key == "2" then
		menu:addPlayer(2)
	elseif key == "3" then
		menu:addPlayer(3)
	elseif key == "4" then
		menu:addPlayer(4)
	end

	if key == 'g' then
		-- if we have at least one player we can start
		if menu:hasPlayers() then
			startGame()
		end
	end

	if key == "space" then
		for i = 1, 4, 1 do
			menu:addCredit()
			menu:addPlayer(i)
		end
		startGame()
	end

	if key == '-' then
		field:killPlayers()
	end

	io.flush()
end
