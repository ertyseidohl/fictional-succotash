local Zone = class('Zone')

local Pulse = require 'pulse'

local SEGMENTS = 12
local FILL_SPEED = 0.5 / BPS
local INNER_RINGS = INNER_RINGS

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
	self.pulseCount = 0
	self.nextPulses = {}
	self.nextPulsesCount = 0

	self.blockedState = {
		isBlocked = false
	}

	self.isStopped = false
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

	local blurSize = math.rad(ZONE_BLUR_SIZE)

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

	if clock.eighth_count % 2 == 1 then
		-- blur

		love.graphics.setColor(color[1], color[2], color[3], ZONE_BLUR_INTENSITY)
		love.graphics.setLineWidth(lineWidth + 10)

		love.graphics.arc(
			'line',
			'open',
			self.center.x,
			self.center.y,
			radius,
			fillStart - blurSize / 2,
			fillEnd + blurSize / 2,
			SEGMENTS
		)

		love.graphics.setLineWidth(lineWidth + 15)

		love.graphics.arc(
			'line',
			'open',
			self.center.x,
			self.center.y,
			radius,
			fillStart - blurSize,
			fillEnd + blurSize,
			SEGMENTS
		)
	end
end


function Zone:update(dt, clock)

	for k, pulse in pairs(self.pulses) do
		pulse:update(dt)

		if pulse.fillAmount <= 0 then
			table.remove(self.pulses, k)

		elseif not clock['is_on_eighth'] or not pulse:isFilled() then
			self:putPulse(pulse)
		elseif self.isBlast then
			-- pass
		else
			local nextRing = self.ring + pulse.direction
			if (nextRing < INNER_RINGS) then
				self:putPulse(pulse)
				self.isStopped = true
			else
				local nextZone = field:getZone(nextRing, self.slice)
				local nextPulse = nextZone:getPulse()

				if nextPulse == nil then
					nextZone:putPulse(pulse)
				else
					if pulse.direction == nextPulse.direction then
						if nextZone.isStopped then
							self:putPulse(pulse)
							self.isStopped = true
						else
							nextZone:putPulse(pulse)
						end
					else
						nextZone:dropPulses()
						if not nextPulse:isFilled() then
							nextZone:putPulse(pulse)
						end
					end
				end
			end
		end
	end
end

function Zone:postUpdate(dt, clock)

	if self.nextPulsesCount > 1 then
		self.nextPulses = {}
		self.nextPulsesCount = 0
	end

	self.pulseCount = self.nextPulsesCount
	self.nextPulsesCount = 0
	self.pulses = self.nextPulses
	self.nextPulses = {}
end

function Zone:isBlocked()
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
	self.nextPulsesCount = self.nextPulsesCount + 1
end

function Zone:getPulse()
	return self.pulses[next(self.pulses)]
end

function Zone:dropPulses()
	self.pulses = {}
	self.pulseCount = 0
	self.isStopped = false
end

function Zone:fill(dt, ship, fromInner)

	if self.pulses[ship.number] == nil then
		if self.pulseCount > 0 then
			return
		end
		self.pulses[ship.number] = Pulse:new(ship, FILL_SPEED, self.startRadians, fromInner)
	end
	self.pulses[ship.number]:fill(dt)
end

function Zone:contains(angle)
	return self.startRadians < angle and self.endRadians > angle
end

return Zone
