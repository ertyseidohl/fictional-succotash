local Pulse = class('Pulse')

function Pulse:initialize(ship, fillTarget, angle)
	self.ship = ship
	self.fillAmount = 0
	self.fillTarget = fillTarget
	self.angle = angle
	self.direction = -1
end

function Pulse:update(dt)
	if self:isFilled() then
		return
	end

	self.fillAmount = self.fillAmount - dt
end

function Pulse:fill(dt)
	self.fillAmount = self.fillAmount + (2 * dt)
end

function Pulse:isFilled()
	return self.fillAmount > self.fillTarget
end

function Pulse:getPercentFilled()
	return self.fillAmount / self.fillTarget
end

function Pulse:reverseDirection()
	self.direction = self.direction * -1
end

return Pulse
