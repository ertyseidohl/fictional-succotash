local Field = class('Field')

local Zone = require 'zone'

function Field:initialize(rings, slices, maxRadius)
	self.rings = rings
	self.slices = slices
	self.maxRadius = maxRadius
	self.zones = {}
	self.center = {
		x = WIDTH / 2,
		y = HEIGHT / 2
	}

	self:generateZones()
end

function Field:generateZones()
	local radialWidth = (2 * math.pi) / self.slices
	local radiusIncrement = (self.maxRadius / self.rings) * 0.5
	for ring = 1, self.rings, 1 do
		for slice = 1, self.slices, 1 do
			--love.event.quit()
			table.insert(self.zones, Zone:new(
				self.center,
				(slice - 1) * radialWidth,
				(slice) * radialWidth,
				(ring - 1) * radiusIncrement,
				(ring) * radiusIncrement
			))
		end
	end
end

function Field:draw()
	for _, zone in pairs(self.zones) do
		zone:draw()
	end
end

function Field:update()
	for _, zone in pairs(self.zones) do
		zone:update()
	end
end

return Field
