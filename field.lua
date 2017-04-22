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

	self.radialWidth = (2 * math.pi) / self.slices
	self:generateZones()
end

function Field:generateZones()
	local radiusIncrement = (self.maxRadius / self.rings) * 0.5
	for ring = 1, self.rings, 1 do
		for slice = 1, self.slices, 1 do
			--love.event.quit()
			table.insert(self.zones, Zone:new(
				self.center,
				(slice - 1) * self.radialWidth,
				(slice) * self.radialWidth,
				(ring - 1) * radiusIncrement,
				(ring) * radiusIncrement
			))
		end
	end
end

-- don't forget these are 1 indexed!
function Field:getZone(slice, ring)
	local index = self.slices * (ring - 1) + slice
	return self.zones[index]
end

function Field:fire(ship)
	local zone = self:getZone(math.ceil(ship.angle / self.radialWidth), self.rings)
end

function Field:draw(clock)
	for _, zone in pairs(self.zones) do
		zone:draw(clock)
	end
end

function Field:update()
	for _, zone in pairs(self.zones) do
		zone:update()
	end
end

return Field