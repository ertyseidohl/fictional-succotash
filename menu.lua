local Menu = class('Menu')

function Menu:initialize()

end

function Menu:update()

end

function Menu:draw()
	for player = 1, 4, 1 do
		if playerSystem.playerStates[player] == PLAYER_STATE_ALIVE then
			love.graphics.setColor(PLAYER_COLORS[player])
			love.graphics.rectangle('fill', (player - 1) * WIDTH / 4, 0, WIDTH / 4, HEIGHT)
		end
	end

	-- debug
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print("Credits: " .. playerSystem.credits, 100, 100)
	love.graphics.print("space to jump in with 4 players", 100, 300)
	love.graphics.print("i to add quarter", 100, 350)
	love.graphics.print("1,2,3,4 to add player (with credit)", 100, 400)
	love.graphics.print("g to start game (with players)", 100, 450)
end

return Menu
