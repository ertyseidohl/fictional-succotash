local WIDTH = 800
local HEIGHT = 600

function love.draw()
    love.graphics.print('Hello World!', WIDTH / 2, HEIGHT / 2)
end

function love.update()
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

