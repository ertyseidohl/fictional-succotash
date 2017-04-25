local PlayerSystem = class('PlayerSystem')

function PlayerSystem:initialize()
	self.credits = 0

	self.playerStates = {
		PLAYER_STATE_NONE,
		PLAYER_STATE_NONE,
		PLAYER_STATE_NONE,
		PLAYER_STATE_NONE
	}

	self.playerCountdowns = {
		0,
		0,
		0,
		0
	}
	self.playerCountdownTimer = 0

	self.playerScores = {
		{score = 0, digits = 1,},
		{score = 0, digits = 1,},
		{score = 0, digits = 1,},
 		{score = 0, digits = 1,},
	}

end

function PlayerSystem:addPlayer(player)
	if self.playerStates[player] == PLAYER_STATE_NONE and
		self:removeCredit()
	then
		self:setPlayerState(player, PLAYER_STATE_ALIVE)
		field:addShip(player)
		self.playerCountdowns[player] = 0
	end

	if self.playerStates[player] == PLAYER_STATE_CONTINUE and
		self:removeCredit()
	then
		self:setPlayerState(player, PLAYER_STATE_ALIVE)
		field:addShip(player)
		self.playerCountdowns[player] = 0
		field:makeShipInvincible(player)
		if gameState == STATE_GAME_OVER then
			resurrectGame()
		end
	end
end

function PlayerSystem:draw()

	for i = 1, 4, 1 do
		local drawX = SCORE_BOXES[i].x
		local drawY = SCORE_BOXES[i].y

		if field.ships[i] ~= nil then
			love.graphics.setColor(unpack(field.ships[i].color))
		end

		love.graphics.polygon('fill', {
			drawX, drawY + 8,
			drawX+9, drawY+28,
			drawX-9, drawY+28
		})

		love.graphics.setFont(FONT_LARGE)
		if i <= 2 then
			love.graphics.print(self.playerScores[i].score, drawX + 14, drawY)
		else
			love.graphics.print(self.playerScores[i].score, drawX - (FONT_LARGE_WIDTH_PIXELS * self.playerScores[i].digits) - 14, drawY)
		end

		love.graphics.setFont(FONT_MEDIUM)
		love.graphics.setColor(unpack(TEXT_COLOR))
		if self.playerStates[i] == PLAYER_STATE_CONTINUE then
			if i <= 2 then
				love.graphics.print("CONTINUE?", drawX, drawY + FONT_LARGE_HEIGHT_PIXELS + 4)
				love.graphics.print(self.playerCountdowns[i], drawX + FONT_MEDIUM_WIDTH_PIXELS * 11 , drawY + FONT_LARGE_HEIGHT_PIXELS + 4)
			else
				love.graphics.print("CONTINUE?", drawX - FONT_MEDIUM_WIDTH_PIXELS * 11 , drawY + FONT_LARGE_HEIGHT_PIXELS + 4)
				love.graphics.print(self.playerCountdowns[i], drawX, drawY + FONT_LARGE_HEIGHT_PIXELS + 4)
			end
		end

	end


	for i = 1, self.credits, 1 do
		love.graphics.setColor(COIN_COLOR)
		love.graphics.circle('fill', (COIN_SIZE + COIN_BUFFER) * i, HEIGHT - COIN_SIZE, COIN_SIZE / 2)
		love.graphics.setColor(COIN_ACCENT)
		love.graphics.setLineWidth(1)
		love.graphics.circle('line', (COIN_SIZE + COIN_BUFFER) * i, HEIGHT - COIN_SIZE, COIN_SIZE / 2)
	end
end

function PlayerSystem:update(dt, clock)

	if clock.is_on_quarter then
		for i = 1, 4, 1 do
			if self.playerStates[i] == PLAYER_STATE_ALIVE then
				self:incrementScore(i, SCORE_INCREMENT)
			end
		end
	end

	if self.playerCountdownTimer == 0 then
		for i = 1, 4, 1 do
			if self.playerCountdowns[i] > 0 then
				self.playerCountdowns[i] = self.playerCountdowns[i] - 1
			elseif self.playerCountdowns[i] == 0 and self.playerStates[i] == PLAYER_STATE_CONTINUE then
				self.playerStates[i] = PLAYER_STATE_NONE
			end
		end

		if not self:hasPlayers() and gameState == STATE_GAME_OVER then
			backToMenu()
		end
	end
	self.playerCountdownTimer = self.playerCountdownTimer + 1
	if self.playerCountdownTimer == 60 then
		self.playerCountdownTimer = 0
	end
end

function PlayerSystem:incrementScore(player, increment)
	if self.playerStates[player] == PLAYER_STATE_ALIVE then

		self.playerScores[player].score = self.playerScores[player].score + increment

		if self.playerScores[player].score < 10 then
			self.playerScores[player].digits = 1
		elseif self.playerScores[player].score < 100 then
			self.playerScores[player].digits = 2
		elseif self.playerScores[player].score < 1000 then
			self.playerScores[player].digits = 3
		elseif self.playerScores[player].score < 10000 then
			self.playerScores[player].digits = 4
		elseif self.playerScores[player].score < 100000 then
			self.playerScores[player].digits = 5
		elseif self.playerScores[player].score < 1000000 then
			self.playerScores[player].digits = 6
		elseif self.playerScores[player].score < 10000000 then
			self.playerScores[player].digits = 7
		elseif self.playerScores[player].score < 100000000 then
			self.playerScores[player].digits = 8
		end
	end
end

function PlayerSystem:addCredit()
	self.credits = self.credits + 1
end

function PlayerSystem:notifyOfDeath(player)
	self:setPlayerState(player, PLAYER_STATE_CONTINUE)
	self:startCountdown(player)
end

function PlayerSystem:startCountdown(player)
	self.playerCountdowns[player] = GAME_OVER_COUNTDOWN_MAX
end

function PlayerSystem:setPlayerState(player, state)
	self.playerStates[player] = state
end

function PlayerSystem:removeCredit()
	if self.credits > 0 then
		self.credits = self.credits - 1
		return true
	else
		return false
	end
end

function PlayerSystem:hasPlayers()
	for i = 1, 4, 1 do
		if self.playerStates[i] ~= PLAYER_STATE_NONE then
			return true
		end
	end
	return false
end

function PlayerSystem:getAlivePlayerCount()
	local count = 0
	for i = 1, 4, 1 do
		if self.playerStates[i] == PLAYER_STATE_ALIVE then
			count = count + 1
		end
	end
	return count
end

return PlayerSystem
