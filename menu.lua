local Menu = class('Menu')

function Menu:initialize()
	self.credits = 0
	self.players = {false, false, false, false}
end

function Menu:update()

end

function Menu:draw()
	for player = 1, 4, 1 do
		if self.players[player] then
			love.graphics.setColor(PLAYER_COLORS[player])
			love.graphics.rectangle('fill', (player - 1) * WIDTH / 4, 0, WIDTH / 4, HEIGHT)
		end
	end

	-- debug
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print("Credits: " .. self.credits, 100, 100)
	love.graphics.print("space to jump in with 4 players", 100, 300)
	love.graphics.print("i to add quarter", 100, 350)
	love.graphics.print("1,2,3,4 to add player (with credit)", 100, 400)
	love.graphics.print("g to start game (with players)", 100, 450)
end

function Menu:addCredit()
	self.credits = self.credits + 1
end

function Menu:removeCredit()
	if self.credits > 0 then
		self.credits = self.credits - 1
		return true
	else
		return false
	end
end

function Menu:addPlayer(player)
	if not self.players[player] and self:removeCredit() then
		self.players[player] = true
	end
end

function Menu:hasPlayers()
	for i = 1, 4, 1 do
		if self.players[i] then
			return true
		end
	end
	return false
end

function Menu:clearPlayers()
	self.players = {false, false, false, false}
end

return Menu
