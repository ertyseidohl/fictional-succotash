local Zone = class('Zone')

local Pulse = require 'pulse'

local SEGMENTS = 12
local FILL_SPEED = 0.5 / BPS

function Zone:initialize(ring, slice, center, startRadians, endRadians, innerRadius, outerRadius, isBlast)
	self.center = center
	self.startRadians = startRadians
	self.endRadians = endRadians
	self.innerRadius = innerRadius
	self.outerRadius = outerRadius
	self.ring = ring
	self.slice = slice
	self.isBlast = isBlast

	self.left = {
		inner = {
			x = self.center.x + (math.cos(startRadians) * innerRadius),
			y = self.center.y + (math.sin(startRadians) * innerRadius)
		},
		outer = {
			x = self.center.x + (math.cos(startRadians) * outerRadius),
			y = self.center.y + (math.sin(startRadians) * outerRadius)
		}
	}
	self.right = {
		inner = {
			x = self.center.x + (math.cos(endRadians) * innerRadius),
			y = self.center.y + (math.sin(endRadians) * innerRadius)
		},
		outer = {
			x = self.center.x + (math.cos(endRadians) * outerRadius),
			y = self.center.y + (math.sin(endRadians) * outerRadius)
		}
	}

	self.pulses = {}
	self.nextPulses = {}

	self.blockedState = {
		isBlocked = false
	}
end

function Zone:draw(clock)

	local pulse = self:getPulse()

	local lineWidth = (self.outerRadius - self.innerRadius)
	local radius = self.innerRadius + (lineWidth / 2)

	local fillStart = self.startRadians
	local fillEnd = self.endRadians

	local color = {}

	if pulse ~= nil then
		color = pulse.ship.color

		if not pulse:isFilled() then
			local width = (fillEnd - fillStart)
			fillStart = self.startRadians + (width / 2) - pulse:getPercentFilled() * width / 2
			fillEnd = self.startRadians + (width / 2) + pulse:getPercentFilled() * width / 2
		end
	elseif self.blockedState.isBlocked then
		color = self.blockedState.color
	else
		return
	end

	love.graphics.setLineWidth(lineWidth)
	love.graphics.setColor(unpack(color))

	love.graphics.arc(
		'line',
		'open',
		self.center.x,
		self.center.y,
		radius,
		fillStart,
		fillEnd,
		SEGMENTS
	)
end

function Zone:preUpdate(dt, clock)
	if self.blockedState.isBlocked and clock.is_on_eighth then
		self.blockedState.blockedCount = self.blockedState.blockedCount - 1
		if self.blockedState.blockedCount == 0 then
			self.blockedState.isBlocked = false
		end
	end
end

function Zone:update(dt, clock)
	for k, pulse in pairs(self.pulses) do
		pulse:update(dt)

		if pulse.fillAmount <= 0 then
			table.remove(self.pulses, k)

		elseif self.isBlast and clock['is_on_eighth'] then
			return -- drop pulse
		elseif self.isBlast then
			self:putPulse(pulse) -- save pulse until the eigth
		elseif not clock['is_on_eighth'] or not pulse:isFilled() then
			self:putPulse(pulse) -- save pulse until the eighth or until it is filled
			return
		else -- on the eighths for all pulses that are not in blast zones and are filled
			local nextRing = self.ring + pulse.direction
			local nextZone = field:getZone(nextRing, self.slice)

			--try to advance
			--if nextRing < INNER_RINGS or nextZone:getPulse() ~= nil then
			if nextRing < INNER_RINGS or nextZone:isSolid() then
				self:putPulse(pulse)
			else
				nextZone:putPulse(pulse)
			end
		end
	end
end

function Zone:postUpdate(dt, clock)
	local nextPulsesCount = 0
	local nextPulsesKey = 0

	for k, pulse in pairs(self.nextPulses) do
		nextPulsesCount = nextPulsesCount + 1
		nextPulsesKey = k
	end

	--two or more pulses will colide
	if nextPulsesCount > 1 then
		self:setBlocked(self.nextPulses[nextPulsesKey].ship.color)
		self.nextPulses = {}

	elseif nextPulsesCount == 1 then
		for k, pulse in pairs(self.pulses) do
			if pulse.direction ~= self.nextPulses[nextPulsesKey].direction then
				self:setBlocked(pulse.ship.color)
				self.nextPulses = {}
			end
		end
	end

	self.pulses = self.nextPulses
	self.nextPulses = {}
end

function Zone:isSolid()
	return self.blockedState.isBlocked or self:getPulse() ~= nil
end

function Zone:setBlocked(color)
	self.blockedState = {
		isBlocked = true,
		blockedCount = 4,
		color = color
	}
end

function Zone:putPulse(pulse)
	self.nextPulses[pulse.ship.number] = pulse
end

function Zone:getPulse()
	return self.pulses[next(self.pulses)]
end

function Zone:fill(dt, ship, fromInner)
	if self.pulses[ship.number] == nil then
		self.pulses[ship.number] = Pulse:new(ship, FILL_SPEED, self.startRadians, fromInner)
	end
	self.pulses[ship.number]:fill(dt)
end

function Zone:contains(angle)
	return self.startRadians < angle and self.endRadians > angle
end

return Zone
