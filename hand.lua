local Hand = class('Hand')

local HAND_BUFFER = 5
local HAND_HEIGHT = 30
local HAND_RADIAL_WIDTH = math.deg(1)

function Hand:initialize(angle)
	self.angle = angle
end

function Hand:update()
	self.angle = self.angle + 0.001
end

function Hand:draw()
	local innerRadius = field.radiusIncrement * INNER_RINGS
	local point = {
		x = field.center.x + (math.cos(self.angle) * (innerRadius + HAND_BUFFER)),
		y = field.center.y + (math.sin(self.angle) * (innerRadius + HAND_BUFFER))
	}

	local leftArm = {
		x = point.x - (math.cos(self.angle + HAND_RADIAL_WIDTH) * HAND_HEIGHT),
		y = point.y - (math.sin(self.angle + HAND_RADIAL_WIDTH) * HAND_HEIGHT),
	}

	local rightArm = {
		x = point.x - (math.cos(self.angle - HAND_RADIAL_WIDTH) * HAND_HEIGHT),
		y = point.y - (math.sin(self.angle - HAND_RADIAL_WIDTH) * HAND_HEIGHT),
	}

	love.graphics.polygon('fill', {
		leftArm.x, leftArm.y,
		point.x, point.y,
		rightArm.x, rightArm.y
	})
end

return Hand
