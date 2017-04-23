local Zone = class('Zone')

local Pulse = require 'pulse'

local SEGMENTS = 12
local FILL_SPEED = 0.5 / BPS

local GRID_COLORS = {
	{255, 178, 174, 255}, -- pastel red
	{225, 239, 255, 255}, -- pastel blue
	{239, 255, 225, 255}, -- pastel green
	{254, 255, 225, 255}, -- pastel yellow
}

function Zone:initialize(ring, slice, center, startRadians, endRadians, innerRadius, outerRadius, isBlast)
	self.center = center
	self.startRadians = startRadians
	self.endRadians = endRadians
	self.innerRadius = innerRadius
	self.outerRadius = outerRadius
	self.ring = ring
	self.slice = slice
	self.isBlast = isBlast

	if ring == 1 then
		innerRadius = 5 + ((slice % 3) * 3)
	end

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

	self.isBlocked = false
	self.blockCount = 0

	self.pulses = {}
	self.nextPulses = {}
end

function Zone:draw(clock)
	love.graphics.setColor(255,255,255,255)

	local hasPulse = next(self.pulses) ~= nil
	if hasPulse or self.isBlocked then

		local pulse = self.pulses[next(self.pulses)]
		local lineWidth = (self.outerRadius - self.innerRadius)
		local radius = self.innerRadius + (lineWidth / 2)
		local oldLineWidth = love.graphics.getLineWidth()

		love.graphics.setLineWidth(lineWidth)

		local fillStart = self.startRadians
		local fillEnd = self.endRadians

		if (hasPulse) then
			love.graphics.setColor(unpack(pulse.ship.color))

			if not pulse:isFilled() then
				local width = (fillEnd - fillStart)
				fillStart = self.startRadians + (width / 2) - pulse:getPercentFilled() * width / 2
				fillEnd = self.startRadians + (width / 2) + pulse:getPercentFilled() * width / 2
			end
		end

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

		love.graphics.setColor(255, 255, 255, 255)

		-- blinking white

		-- if hasPulse and clock.eighth_count % 2 == 0 then
		-- 	love.graphics.arc(
		-- 		'line',
		-- 		'open',
		-- 		self.center.x,
		-- 		self.center.y,
		-- 		radius,
		-- 		self.startRadians,
		-- 		self.endRadians,
		-- 		SEGMENTS
		-- 	)
		-- end
		love.graphics.setLineWidth(oldLineWidth)
	end

end

function Zone:update(dt, clock)

	if self.isBlocked then
		if clock.is_on_quarter then
			self.blockedCount = self.blockedCount - 1
		end
		if self.blockedCount <= 0 then
			self.isBlocked = false
		end
	end


	for k, pulse in pairs(self.pulses) do
		pulse:update(dt)

		if pulse.fillAmount < 0 then
			table.remove(self.pulses, k)

		elseif clock['is_on_eighth'] and pulse:isFilled() then
			local nextRing = self.ring + pulse.direction
			local nextSlice = self.slice
			if nextRing == 0 then
				nextRing = self.ring
				nextSlice = (self.slice + (field.slices / 2)) % field.slices
				pulse:reverseDirection()
			end
			local zone = field:getZone(nextRing, nextSlice)

			if zone ~= nil then
				zone:putPulse(pulse)
			end
		else
			self:putPulse(pulse)
		end

	end
end

function Zone:postUpdate(dt, clock)

	if self.isBlocked then
		self.nextPulses = {}
		self.pulses = {}
	end

	local nextPulsesCount = 0
	local nextPulsesKey = 0

	for k, pulse in pairs(self.nextPulses) do
		nextPulsesCount = nextPulsesCount + 1
		nextPulsesKey = k
	end

	--two or more pulses will colide
	if nextPulsesCount > 1 then
		self:setBlocked()
	elseif nextPulsesCount == 1 then
		for k, pulse in pairs(self.pulses) do
			if pulse.angle ~= self.nextPulses[nextPulsesKey].angle then
				self:setBlocked()
			end
		end
	end

	if not self.isBlocked then
		self.pulses = self.nextPulses;
	else
		self.pulses = {}
	end

	self.nextPulses = {}
end


function Zone:setBlocked()
	self.isBlocked = true
	self.blockedCount = 4
end

function Zone:putPulse(pulse)
	self.nextPulses[pulse.ship.number] = pulse
end

function Zone:hasEnemyPulse(ship)
	for _, pulse in pairs(self.pulses) do
		if pulse.ship.number ~= ship.number then
			return true
		end
	end
	return false
end

function Zone:fill(dt, ship)
	if self.pulses[ship.number] == nil then
		self.pulses[ship.number] = Pulse:new(ship, FILL_SPEED, self.startRadians)
	end
	self.pulses[ship.number]:fill(dt)
end

function Zone:contains(angle)
	return self.startRadians < angle and self.endRadians > angle
end

return Zone
