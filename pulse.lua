local Pulse = class('Pulse')

function Pulse:initialize(ship, fillTarget, angle, fromInner)
	self.ship = ship
	self.fillAmount = 0
	self.fillTarget = fillTarget
	self.angle = angle
	if fromInner then
		self.direction = 1
	else
		self.direction = -1
	end
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
