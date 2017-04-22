local Pulse = class('Pulse')

function Pulse:initialize(ship, fillTarget)
	self.ship = ship
	self.fillAmmount = 0
	self.fillTarget = fillTarget
	self.direction = -1
	self.moved = false
end

function Pulse:update(dt)
	self.moved = false
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

function Pulse:hasMoved()
	return self.moved
end

function Pulse:setMoved()
	self.moved = true
end

function Pulse:getDirection()
	return self.direction
end

function Pulse:reverseDirection()
	self.direction = self.direction * -1
end

return Pulse
