local Menu = class('Menu')

local credits = {
	{text = 'Project Lead', title=true, length=135},
	{text = 'ERTY SEIDOHL', length=158},
	{text = 'Software Engineers', title=true, length=213},
	{text = 'RYAN MCVERRY', length=173},
	{text = 'MAX FELDKAMP', length=173},
	{text = 'Hardware Engineer', title=true, length=212},
	{text = 'BEN GOODING', length=159},
	{text = 'Music and Sound', title=true, length=188},
	{text = 'EVAN CONWAY', length=164},
	{text = 'Cabinet Construction', title=true, length=232},
	{text = 'ERIC VAN DER HEIDE', length=236},
	{text = 'MATT GOLON', length=145},
	{text = 'Cabinet Art', title=true, length=125},
	{text = 'HALEY WHITE-BALLOWE', length=263},
}

local creditsLength = 14
local creditPosition = 1
local creditCounter = 0

local myState = 'none'
local ships = {
	{x = 0, d = 0, offset = 0, speed = 1},
	{x = -33, d = math.pi / 2, offset = 33, speed = 2},
	{x = -66, d = math.pi / 3, offset = 66, speed = 3},
	{x = -100, d = math.pi / 4, offset = 100, speed = 4},
}

function Menu:initialize()

end

function Menu:update(dt, clock, menuState)
	if gameState ~= STATE_MENU then
		return
	end
	if menuState == MENU_STATE_GAMEPLAY then
		if myState ~= MENU_STATE_GAMEPLAY then
			musicsystem:gameStart()
			field:buildShips({PLAYER_STATE_ALIVE, PLAYER_STATE_ALIVE, PLAYER_STATE_ALIVE, PLAYER_STATE_ALIVE})
		else
			field:update(dt, clock, true)
		end
	end
	myState = menuState
end

function Menu:draw(clock, menuState)

	if gameState == STATE_POSTMENU then
		for player = 1, 4, 1 do
			if playerSystem.playerStates[player] == PLAYER_STATE_ALIVE then
				love.graphics.setColor(PLAYER_COLORS[player])
				love.graphics.rectangle('fill', (player - 1) * WIDTH / 4, 0, WIDTH / 4, HEIGHT)
			end
		end
		return
	end

	if menuState == MENU_STATE_TEXT then
		self:drawText()
	elseif menuState ==  MENU_STATE_CREDITS then
		self:drawCredits()
	elseif menuState ==  MENU_STATE_GAMEPLAY then
		self:drawGameplay(clock)
	end

	if DEBUG then
		love.graphics.setColor({255, 255, 255, 255})
		love.graphics.print("Credits: " .. playerSystem.credits, 100, 100)
		love.graphics.print("space to jump in with 4 players", 100, 300)
		love.graphics.print("i to add quarter", 100, 350)
		love.graphics.print("1,2,3,4 to add player (with credit)", 100, 400)
		love.graphics.print("g to start game (with players)", 100, 450)
	end
end

function Menu:drawGameplay(clock)
	field:draw(clock)
end


function Menu:drawCredits()

	self.drawLogo()
	love.graphics.setColor(TEXT_COLOR)
	love.graphics.setFont(FONT_CREDITS)

	while not credits[creditPosition].title do
		creditPosition = creditPosition + 1
		if creditPosition > creditsLength then
			creditPosition = 1
		end
	end

	local x = (WIDTH / 2) - (credits[creditPosition].length / 2)
	local y = (HEIGHT / 2) + (FONT_CREDITS_HEIGHT_PIXELS * 4)

	local title = credits[creditPosition].text
	love.graphics.print(title, x, y)

	local namePosition = creditPosition + 1
	while namePosition <= creditsLength and not credits[namePosition].title do
		local i = namePosition - creditPosition
		local name = credits[namePosition].text
		local x = (WIDTH / 2) - (credits[namePosition].length / 2)
		local y = (HEIGHT / 2) + (FONT_CREDITS_HEIGHT_PIXELS * (4 + (2 * i)))

		love.graphics.print(name, x, y)
		namePosition = namePosition + 1
	end

	if creditCounter > 120 then
		creditPosition = creditPosition + 1
		creditCounter = 0
	end

	creditCounter = creditCounter + 1
end

function Menu:drawLogo()
	local x = (WIDTH / 2) - (GAME_NAME_LENGTH / 2)
	local y = (HEIGHT / 2) - (FONT_TITLE_HEIGHT_PIXELS / 2)

	love.graphics.setColor(DEVIL_COLOR)
	love.graphics.setFont(FONT_TITLE)
	love.graphics.print(GAME_NAME, x, y)
end

function Menu:drawText()
	self:drawLogo()
	local cnt = 0
	for player = 1, 4, 1 do
		ship = ships[player]
		love.graphics.setColor(PLAYER_COLORS[player])

		local point =  {
			x = ship.x,
			y = HEIGHT / 2 + (math.sin(ship.d) * 200)
		}
		local angle = math.cos(ship.d) + math.pi

		local leftArm = {
			x = point.x + (math.cos(angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
			y = point.y + (math.sin(angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		}

		local rightArm = {
			x = point.x + (math.cos(angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
			y = point.y + (math.sin(angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		}
		love.graphics.polygon('fill', {
			leftArm.x, leftArm.y,
			point.x, point.y,
			rightArm.x, rightArm.y
		})

		ship.d = ship.d + ((math.pi / 256) * (1 + ship.speed / 8))
		ship.x = ship.x + 3 + (ship.speed / 4) * 2

		if ship.x > WIDTH then
			cnt = cnt + 1
		end
	end

	if cnt == 4 then
		for player = 1, 4, 1 do
			ship = ships[player]
			ship.x = math.min(ship.x - WIDTH * 1.5, ship.offset - 1)

			ship.speed = ship.speed - 1
			if ship.speed == 0 then
				ship.speed = 4
			end
		end
	end

end

return Menu
