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
end

function Zone:draw(clock)
	love.graphics.setColor(255,255,255,255)
	local inc = (255 / clock.eighths) * clock.beat

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
	if next(self.pulses) ~= nil then
		local lineWidth = (self.outerRadius - self.innerRadius)
		local radius = self.innerRadius + (lineWidth / 2)
		local oldLineWidth = love.graphics.getLineWidth()
		love.graphics.setColor(255, 255, 255, inc)
		love.graphics.setLineWidth(lineWidth)
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
		love.graphics.setLineWidth(oldLineWidth)
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.line(self.left.inner.x, self.left.inner.y, self.left.outer.x, self.left.outer.y)
	love.graphics.line(self.right.inner.x, self.right.inner.y, self.right.outer.x, self.right.outer.y)
end

function Zone:update(dt, clock)
	for k, pulse in pairs(self.pulses) do
		local remove = false
		pulse:update(dt)

		print(pulse.fillAmmount)
		if clock['is_on_quarter'] and pulse:isFilled() then
			local zone = field:getZone(self.ring - 1, self.slice)
			zone:putPulse(pulse)
			remove = true
		end

		if pulse.fillAmmount < 0 then
			remove = true
		end

		if remove then
			table.remove(self.pulses, k)
		end
	end
end

function Zone:putPulse(pulse)
	--self.pulses[pulse.ship.number] = pulse
end

function Zone:fill(dt, ship)
	if self.pulses[ship.number] == nil then
		self.pulses[ship.number] = Pulse:new(ship, 2)
	end
	self.pulses[ship.number]:fill(dt)
end

return Zone
