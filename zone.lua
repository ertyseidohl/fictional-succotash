local Zone = class('Zone')

local Pulse = require 'pulse'

local SEGMENTS = 5

function Zone:initialize(ring, slice, center, startRadians, endRadians, innerRadius, outerRadius)
	self.center = center
	self.startRadians = startRadians
	self.endRadians = endRadians
	self.innerRadius = innerRadius
	self.outerRadius = outerRadius
	self.ring = ring
	self.slice = slice

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

	if ring == 2 and slice % 4 == 0 then
		self.isBlocked = true
	end

	self.pulses = {}
	self.nextPulses = {}
end

function Zone:draw(clock)
	love.graphics.setColor(255,255,255,255)
	--if next(self.pulses) == nil then
		love.graphics.arc(
			'line',
			'open',
			self.center.x,
			self.center.y,
			self.innerRadius,
			self.startRadians,
			self.endRadians,
			SEGMENTS
		)
		love.graphics.arc(
			'line',
			'open',
			self.center.x,
			self.center.y,
			self.outerRadius,
			self.startRadians,
			self.endRadians,
			SEGMENTS
		)

	local hasPulse = next(self.pulses) ~= nil

	if hasPulse or self.isBlocked then

		local pulse = self.pulses[next(self.pulses)]
		local lineWidth = (self.outerRadius - self.innerRadius)
		local radius = self.innerRadius + (lineWidth / 2)
		local oldLineWidth = love.graphics.getLineWidth()

		love.graphics.setLineWidth(lineWidth)

		if hasPulse then
			love.graphics.setColor(unpack(pulse.ship.color))
		end

		love.graphics.arc(
			'line',
			'open',
			self.center.x,
			self.center.y,
			radius,
			self.startRadians,
			self.endRadians,
			SEGMENTS
		)

		love.graphics.setColor(255, 255, 255, 255)

		if hasPulse and clock.eighth_count % 2 == 0 then
			love.graphics.arc(
				'line',
				'open',
				self.center.x,
				self.center.y,
				radius,
				self.startRadians,
				self.endRadians,
				SEGMENTS
			)
		end
		love.graphics.setLineWidth(oldLineWidth)
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.line(self.left.inner.x, self.left.inner.y, self.left.outer.x, self.left.outer.y)
	love.graphics.line(self.right.inner.x, self.right.inner.y, self.right.outer.x, self.right.outer.y)
end

function Zone:update(dt, clock)
	for k, pulse in pairs(self.pulses) do
		pulse:update(dt)

		if pulse.fillAmmount < 0 then
			table.remove(self.pulses, k)

		elseif clock['is_on_quarter'] and pulse:isFilled() then
			local nextRing = self.ring + pulse:getDirection()
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

	if not self.isBlocked then
		local cnt = 0;
		for k, pulse in pairs(self.nextPulses) do
			cnt = cnt + 1
		end

		if cnt > 2 then
			self.isBlocked = true
		else
			self.pulses = self.nextPulses;
		end
	end

	self.nextPulses = {}
end


function Zone:putPulse(pulse)
	self.nextPulses[pulse.ship.number] = pulse
end

function Zone:fill(dt, ship)
	if self.pulses[ship.number] == nil then
		self.pulses[ship.number] = Pulse:new(ship, 2)
	end
	self.pulses[ship.number]:fill(dt)
end

return Zone
