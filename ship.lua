local Ship = class("Ship")

SHIP_RADIAL_WIDTH = math.rad(25);
SHIP_HEIGHT = 25;
SHIP_BUFFER = 10;

function Ship:initialize(number, color, startAngle)
	self.number = number
	self.color = color
	self.angle = startAngle
end

function Ship:draw()
	local point = {
		x = field.center.x + (math.cos(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER)),
		y = field.center.y + (math.sin(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER))
	}

	local leftArm = {
		x = point.x + (math.cos(self.angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		y = point.y + (math.sin(self.angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
	}

	local rightArm = {
		x = point.x + (math.cos(self.angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		y = point.y + (math.sin(self.angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
	}

	love.graphics.setColor(unpack(self.color))
	love.graphics.polygon('fill', {
		leftArm.x, leftArm.y,
		point.x, point.y,
		rightArm.x, rightArm.y
	})
end

function Ship:update()
	self.angle = self.angle + 0.005
end

return Ship
