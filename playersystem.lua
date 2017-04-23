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

	self.playerScores = {
		0,
		0,
		0,
		0,
	}
end

function PlayerSystem:addPlayer(player)
	if self.playerStates[player] == PLAYER_STATE_NONE and
		self:removeCredit()
	then
		self:setPlayerState(player, PLAYER_STATE_ALIVE)
	end

	if self.playerStates[player] == PLAYER_STATE_CONTINUE and
		self:removeCredit()
	then
		self:setPlayerState(player, PLAYER_STATE_ALIVE)
		field:addShip(player)
		self.playerCountdowns[player] = 0
		if gameState == STATE_GAME_OVER then
			resurrectGame()
		end
	end
end

function PlayerSystem:draw()

	for i = 1, 4, 1 do
		love.graphics.setColor(unpack(TEXT_COLOR))
		if self.playerStates[i] == PLAYER_STATE_CONTINUE then
			love.graphics.print("CONTINUE?", 100 * i, HEIGHT - 100)
			love.graphics.print(self.playerCountdowns[i], 100 * i, HEIGHT - 75)
		end

		love.graphics.print(self.playerScores[i], 200 * i, HEIGHT - 100)
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
				self.playerScores[i] = self.playerScores[i] + SCORE_INCREMENT
			end
		end
	end

	if clock.is_on_whole then
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
