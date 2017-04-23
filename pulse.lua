local Pulse = class('Pulse')

function Pulse:initialize(ship, fillTarget, angle)
	self.ship = ship
	self.fillAmmount = 0
	self.fillTarget = fillTarget
	self.angle = angle
	self.direction = -1
end

function Pulse:update(dt)
	if self:isFilled() then
		return
	end

	self.fillAmmount = self.fillAmmount - dt
end

function Pulse:fill(dt)
	self.fillAmmount = self.fillAmmount + (2 * dt)
end

function Pulse:isFilled()
	return self.fillAmmount > self.fillTarget
end

function Pulse:getPercentFilled()
	return self.fillAmmount / self.fillTarget
end

function Pulse:reverseDirection()
	self.direction = self.direction * -1
end

return Pulse
