class = require 'lib/middleclass'

DEBUG = false

GAME_NAME = 'RADION'
GAME_NAME_LENGTH = 379

-- global settings
BPM = 300 -- debug
BPS = BPM / 60
WIDTH = 1280
HEIGHT = 1024
MAXRADIUS = math.min(WIDTH, HEIGHT) * 0.8
INNER_RINGS = 3
PLAYER_COLORS = {
	{255,0,0,255},
	{0,0,255,255},
	{255,255,0,255},
	{0,255,0,255}
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

--scoringg
SCORE_INCREMENT = 66
SCORE_CENTER_RING = 101
SCORE_FULL_RING = 999
SCORE_BOX_BUFFER = 40

SCORE_BOXES = {
	{x = SCORE_BOX_BUFFER, y = SCORE_BOX_BUFFER},
	{x = SCORE_BOX_BUFFER, y = HEIGHT - SCORE_BOX_BUFFER},
	{x = WIDTH - SCORE_BOX_BUFFER, y = SCORE_BOX_BUFFER},
	{x = WIDTH - SCORE_BOX_BUFFER, y = HEIGHT - SCORE_BOX_BUFFER},
}

DO_BLUR = false
BLUR_SEGMENTS = 3
ZONE_BLUR_SIZE = 2
ZONE_BLUR_INTENSITY = 64 -- opacity of outermost blur out of 255
RING_BLUR_SIZE = 5 -- in pixels
RING_BLUR_INTENSITY = 64
RING_LINE_WIDTH = 2
SHIP_BLUR_SIZE = 5
SHIP_BLUR_INTENSITY = 64
DEVIL_BLUR_SIZE = 5
DEVIL_BLUR_INTENSITY = 64

PLAYER_KEYS = {
	{cc = 'z', c = 'x', f = 's', jcc = 11, jc = 10, jf = 12},
	{cc = 'c', c = 'v', f = 'f', jcc = 6, jc = 4, jf = 5},
	{cc = 'b', c = 'n', f = 'h', jcc = 2, jc = 1, jf = 3},
	{cc = 'm', c = ',', f = 'k', jcc = 9, jc = 7, jf = 8}
}

START_GAME_MAX_COUNT = 400 -- arbitrary
START_GAME_COUNT_MOD = 40

RINGS = 16
SLICES = 32

-- states
STATE_MENU = 0
STATE_PLAYING = 1
STATE_GAME_OVER = 2
STATE_POSTMENU = 4

PLAYER_STATE_NONE = 4
PLAYER_STATE_ALIVE = 1
PLAYER_STATE_CONTINUE = 2

FONT_LARGE_HEIGHT_PIXELS = 32
FONT_LARGE_WIDTH_PIXELS = 20
FONT_LARGE = love.graphics.newFont(32)

FONT_MEDIUM_HEIGHT_PIXELS = 24
FONT_MEDIUM_WIDTH_PIXELS = 14
FONT_MEDIUM = love.graphics.newFont(24)

FONT_TITLE_WIDTH_PIXELS = 54
FONT_TITLE_HEIGHT_PIXELS = 96
FONT_TITLE = love.graphics.newFont(96)

FONT_CREDITS_HEIGHT_PIXELS = 22
FONT_CREDITS_WIDTH_PIXELS = 12
FONT_CREDITS = love.graphics.newFont(22)

local Field = require 'field'
local MusicSystem = require 'musicsystem'
local Menu = require 'menu'
local PlayerSystem = require 'playersystem'
local Shine = require 'lib/shine-master'

-- local vars
local screenCapCanvas = love.graphics.newCanvas(WIDTH, HEIGHT)
local gameOverDevilSize = 0
local isGameStarting = false
local menuStartGameCounter = 0

-- global objects
gameState = STATE_MENU
musicsystem = MusicSystem:new()
field = Field:new(RINGS, SLICES, MAXRADIUS, musicsystem)
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
local postEffect = nil

MENU_STATE_CREDITS = 'credits'
MENU_STATE_TEXT = 'text'
MENU_STATE_GAMEPLAY = 'gameplay'

local menuState = MENU_STATE_TEXT
local menuStateIndex = 1
local menuStateMap = {
	MENU_STATE_TEXT,
	MENU_STATE_CREDITS,
	MENU_STATE_TEXT,
	MENU_STATE_GAMEPLAY,
}
local menuStateMapSize = 4
local menuCounter = 0
local menuStateCountdown = 700
--debug
debug_print_keypresses = false

function love.load()
	-- print(name,5,5)
	-- print(version,5,15)
	-- print(vendor,5,25)
	-- print(device ,5,35)

	musicsystem:load()
end

function love.draw()
	if gameState == STATE_PLAYING then
		field:draw(clock)
	elseif gameState == STATE_MENU or gameState == STATE_POSTMENU then
		if menuState == MENU_STATE_GAMEPLAY then
			field:draw(clock)
		end
		menu:draw(clock, menuState)

		if isGameStarting then
			love.graphics.setColor({255, 255, 255, 255})
			-- debug TODO MOVE THIS
			love.graphics.print(10 - (10 * ((menuStartGameCounter - menuStartGameCounter % START_GAME_COUNT_MOD) / START_GAME_MAX_COUNT)), 50, 50)
		end
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

		if (field:devilIsSurrounded()) then
			musicsystem:switchTrack()
			for i = 1, 4, 1 do
				playerSystem:incrementScore(i, RINGS)
			end
			field:upgradeDevil()
			field:clear()
		end
	elseif gameState == STATE_MENU then

		if playerSystem:hasPlayers() then
			gameState = STATE_POSTMENU
		end

		menuCounter = menuCounter + 1
		if menuCounter > menuStateCountdown then
			if menuState == MENU_STATE_GAMEPLAY then
				endGame() 				-- hack to play menu screen music
				backToMenu()
			end
			menuStateIndex = menuStateIndex + 1
			if menuStateIndex > menuStateMapSize then
				menuStateIndex = 1
			end
			menuState = menuStateMap[menuStateIndex]
			menuCounter = 0
		end

		menu:update(dt, clock, menuState)
	elseif gameState == STATE_POSTMENU then
		if menuState == MENU_STATE_GAMEPLAY then
			endGame()
			backToMenu()
			gameState = STATE_POSTMENU
			menuState = MENU_STATE_TEXT
		end
		menu:update(dt, clock, menuState)
	elseif gameState == STATE_GAME_OVER then
		gameOverDevilSize = gameOverDevilSize + GAME_OVER_DEVIL_GROWTH_SPEED
	end

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	playerSystem:update(dt, clock)

	if isGameStarting then
		menuStartGameCounter = menuStartGameCounter + 1

		if menuStartGameCounter == START_GAME_MAX_COUNT then
			startGame()
		end
	end

	--debug
	if love.keyboard.isDown('p') then
		debug_print_keypresses = true
	end
end

function startGame()
	musicsystem:gameStart()
	gameState = STATE_PLAYING
	field:buildShips(playerSystem.playerStates)
	isGameStarting = false
	menuStartGameCounter = 0
end

function endGame()
	musicsystem:gameOver()
	love.graphics.setCanvas(screenCapCanvas)
		love.graphics.clear()
		field:draw(clock)
	love.graphics.setCanvas()
	gameState = STATE_GAME_OVER
end

function backToMenu()
	gameState = STATE_MENU
	gameOverDevilSize = 0
	field:reset()

	--reset the menu
	menuState = MENU_STATE_TEXT
	menuStateIndex = 1
	menuCounter = 0
end

function resurrectGame()
	musicsystem:gameStart()
	gameState = STATE_PLAYING
	gameOverDevilSize = 0
end

function love.joystickaxis(js, axis, val)
	if axis == 2 and val == -1 then
		playerSystem:addCredit()
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

	if key == "q" then
		musicsystem:switchTrack()
	end
	if key == "w" then
		musicsystem:gameStart()
	end
	if key == "e" then
		musicsystem:gameOver()
	end

	if key == "i" then
		playerSystem:addCredit()
	end

	for i = 1, 4, 1 do
		if tostring(i) == key then
			if gameState == STATE_MENU or gameState == STATE_POSTMENU then
				if playerSystem.playerStates[i] == PLAYER_STATE_NONE then
					playerSystem:addPlayer(i)
				else
					isGameStarting = true
				end
			else --STATE_PLAYING or STATE_GAME_OVER
				playerSystem:addPlayer(i)
			end
		end
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

function love.joystickpressed(js, button)
	for i = 1, 4, 1 do
		if (button == PLAYER_KEYS[i]['jf']) then
			if gameState == STATE_MENU or gameState == STATE_POSTMENU then
				if playerSystem.playerStates[i] == PLAYER_STATE_NONE then
					playerSystem:addPlayer(i)
				else
					isGameStarting = true
				end
			else --STATE_PLAYING or STATE_GAME_OVER
				playerSystem:addPlayer(i)
			end
		end
	end
end
