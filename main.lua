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
TEXT_COLOR = {255, 255, 255, 255}

DEVIL_RADIUS = 20
DEVIL_LINE_SEGMENTS = 20
DEVIL_COLOR = {127, 0, 127, 255}
GAME_OVER_DEVIL_GROWTH_SPEED = 10

HAND_BUFFER = 0
HAND_HEIGHT = 15
HAND_RADIAL_WIDTH = math.rad(10)

SHIP_RADIAL_WIDTH = math.rad(25);
SHIP_HEIGHT = 25;
SHIP_BUFFER = 10;

SHIP_ACCELERATION = 0.0025
SHIP_FRICTION = 0.90
SHIP_MAX_VELOCITY = 0.05
SHIP_STARTING_LIVES = 3
SHIP_INVINCIBLE_TIME = 8
SHIP_LIFE_LINE_BUFFER = 10
SHIP_LIFE_LINE_WIDTH = 5
SHIP_LIFE_LINE_ANGLE = math.rad(20)

GAME_OVER_COUNTDOWN_MAX = 10

COIN_SIZE = 30
COIN_BUFFER = 5
COIN_COLOR = {200, 200, 200, 200}
COIN_ACCENT = {220, 220, 230, 200}

--scoring
SCORE_INCREMENT = 66
SCORE_CENTER_RING = 101
SCORE_FULL_RING = 999

SCORE_BOXES = {
	{x = 20,               y = 20},
	{x = 20,               y = HEIGHT - 20},
	{x = WIDTH - 20, y = 20},
	{x = WIDTH - 20, y = HEIGHT - 20},
}

-- states
STATE_MENU = 0
STATE_PLAYING = 1
STATE_GAME_OVER = 2

PLAYER_STATE_NONE = 4
PLAYER_STATE_ALIVE = 1
PLAYER_STATE_CONTINUE = 2

FONT_LARGE_HEIGHT_PIXELS = 32
FONT_LARGE_WIDTH_PIXELS = 20
FONT_LARGE = love.graphics.newFont(32)

FONT_MEDIUM_HEIGHT_PIXELS = 24
FONT_MEDIUM_WIDTH_PIXELS = 14
FONT_MEDIUM = love.graphics.newFont(24)

local Field = require 'field'
local MusicSystem = require 'musicsystem'
local Menu = require 'menu'
local PlayerSystem = require 'playersystem'
local Shine = require 'lib/shine-master'

-- local vars
local screenCapCanvas = love.graphics.newCanvas(WIDTH, HEIGHT)
local gameOverDevilSize = 0

-- global objects
gameState = STATE_MENU
field = Field:new(16, 32, MAXRADIUS)
playerSystem = PlayerSystem:new()
menu = Menu:new()
local joysticks = love.joystick.getJoysticks()
joystick = joysticks[1]

name, version, vendor, device = love.graphics.getRendererInfo()

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

local postEffect = nil

--debug
debug_print_keypresses = false


function love.load()
	print(name,5,5)
	print(version,5,15)
	print(vendor,5,25)
	print(device ,5,35)

	musicsystem = MusicSystem:new()
	postEffect = Shine.boxblur()
end

function love.draw()
	if gameState == STATE_PLAYING then
		postEffect:draw(function()
			field:draw(clock)
		end)
		field:draw(clock)
	elseif gameState == STATE_MENU then
		menu:draw(clock)
	elseif gameState == STATE_GAME_OVER then
		love.graphics.setColor({255, 255, 255, 255})
		love.graphics.draw(screenCapCanvas)
		love.graphics.setColor(DEVIL_COLOR)
		love.graphics.circle('fill', WIDTH / 2, HEIGHT / 2, gameOverDevilSize)
	end

	playerSystem:draw(clock)
end

function love.update(dt)

	if firstUpdate then
		musicsystem:play()
		firstUpdate = false
	end

	--local nextClockTime = clock.time + dt
	local nextClockTime = musicsystem:update(dt)
	local next_clock = {
		full_count = math.floor(nextClockTime * BPS / 4),
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

	if next_clock['full_count'] ~= clock['full_count'] then
		next_clock['is_on_whole'] = true;
	else
		next_clock['is_on_whole'] = false;
	end

	clock = next_clock

	if gameState == STATE_PLAYING then
		field:update(dt, clock)
	elseif gameState == STATE_MENU then
		menu:update(dt, clock)
	elseif gameState == STATE_GAME_OVER then
		gameOverDevilSize = gameOverDevilSize + GAME_OVER_DEVIL_GROWTH_SPEED
	end

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	playerSystem:update(dt, clock)

	--debug
	if love.keyboard.isDown('p') then
		debug_print_keypresses = true
	end
end

function startGame()
	gameState = STATE_PLAYING
	field:buildShips(playerSystem.playerStates)
end

function endGame()
	love.graphics.setCanvas(screenCapCanvas)
		love.graphics.clear()
		field:draw(clock)
	love.graphics.setCanvas()
	gameState = STATE_GAME_OVER
end

function backToMenu()
	gameState = STATE_MENU
	gameOverDevilSize = 0
	field:clear()
end

function resurrectGame()
	gameState = STATE_PLAYING
	gameOverDevilSize = 0
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
		playerSystem:addCredit()
	end

	if key == "1" then
		playerSystem:addPlayer(1)
	elseif key == "2" then
		playerSystem:addPlayer(2)
	elseif key == "3" then
		playerSystem:addPlayer(3)
	elseif key == "4" then
		playerSystem:addPlayer(4)
	end

	if key == 'g' then
		-- if we have at least one player we can start
		if playerSystem:hasPlayers() then
			startGame()
		end
	end

	if key == "space" then
		for i = 1, 4, 1 do
			playerSystem:addCredit()
			playerSystem:addPlayer(i)
		end
		startGame()
	end

	if key == '-' then
		field:killPlayers()
	end

	io.flush()
end
