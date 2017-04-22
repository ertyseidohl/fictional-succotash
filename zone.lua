local Zone = class('Zone')

local SEGMENTS = 5

function Zone:initialize(center, startRadians, endRadians, innerRadius, outerRadius)
	self.center = center
	self.startRadians = startRadians
	self.endRadians = endRadians
	self.innerRadius = innerRadius
	self.outerRadius = outerRadius

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
	if innerRadius > 150 and startRadians < .05 then
		table.insert(self.pulses, "dummy")
	end
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

function Zone:update()

end

return Zone
