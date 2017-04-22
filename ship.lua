local Ship = class("Ship")

function Ship:initialize(number, color, startAngle)
	self.number = number
	self.color = color
	self.angle = startAngle
end

function Ship:draw()

end

function Ship:update()

end

return Ship
