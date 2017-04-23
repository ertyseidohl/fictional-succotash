local Hand = class('Hand')

function Hand:initialize(devil, angle)
	self.angle = angle
	-- to pretent this is a ship
	self.number = 666
end

function Hand:update(dt, clock)
	self.angle = self.angle + 0.001

	if (love.keyboard.isDown('w')) then
		field:fill(dt, self, true)
	end
end

function Hand:draw()
	local innerRadius = field.radiusIncrement * (INNER_RINGS - 1)
	local point = {
		x = field.center.x + (math.cos(self.angle) * (innerRadius - HAND_BUFFER)),
		y = field.center.y + (math.sin(self.angle) * (innerRadius - HAND_BUFFER))
	}

	local leftArm = {
		x = point.x - (math.cos(self.angle + HAND_RADIAL_WIDTH) * HAND_HEIGHT),
		y = point.y - (math.sin(self.angle + HAND_RADIAL_WIDTH) * HAND_HEIGHT),
	}

	local rightArm = {
		x = point.x - (math.cos(self.angle - HAND_RADIAL_WIDTH) * HAND_HEIGHT),
		y = point.y - (math.sin(self.angle - HAND_RADIAL_WIDTH) * HAND_HEIGHT),
	}

	love.graphics.setColor(unpack(DEVIL_COLOR))
	love.graphics.polygon('fill', {
		leftArm.x, leftArm.y,
		point.x, point.y,
		rightArm.x, rightArm.y
	})
end

return Hand
