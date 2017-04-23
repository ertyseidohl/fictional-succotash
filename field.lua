local Field = class('Field')

local Zone = require 'zone'
local Ship = require 'ship'

local RADIAL_WIDTH_HALF = (math.pi * 2 / 32) / 2

function Field:initialize(rings, slices, maxRadius)
	self.rings = rings
	self.slices = slices
	self.maxRadius = maxRadius
	self.zones = {}
	self.ships = {
		Ship:new(1, {255,0,0,255}, RADIAL_WIDTH_HALF, {cc = 'z', c = 'x'}),
		Ship:new(2, {0,0,255,255}, math.pi + RADIAL_WIDTH_HALF, {cc = 'c', c = 'v'}),
		-- Ship:new(3, {0,255,0,255}, math.pi * 0.5 + RADIAL_WIDTH_HALF, {cc = 'b', c = 'n'}),
		-- Ship:new(4, {255,255,0,255}, math.pi * 1.5 + RADIAL_WIDTH_HALF, {cc = 'm', c = ','})
	}
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
				ring,
				slice,
				self.center,
				(slice - 1) * self.radialWidth,
				(slice) * self.radialWidth,
				(ring - 1) * radiusIncrement,
				(ring) * radiusIncrement,
				false
			))
		end
	end

	-- blasts

	for slice = 1, self.slices, 1 do
		--love.event.quit()
		table.insert(self.zones, Zone:new(
			self.rings + 1,
			slice,
			self.center,
			(slice - 1) * self.radialWidth,
			(slice) * self.radialWidth,
			self.maxRadius * 0.5,
			math.max(WIDTH, HEIGHT) - (self.maxRadius * 0.5),
			true
		))
	end

end

-- don't forget these are 1 indexed!
function Field:getZone(ring, slice)
	slice = ((slice - 1) % self.slices) + 1 -- this is why real programmers 0-index!
	local index = self.slices * (ring - 1) + slice
	return self.zones[index]
end

function Field:fill(dt, ship)
	local zone = self:getZone(self.rings, math.ceil(ship.angle / self.radialWidth))
	zone:fill(dt, ship)
end

function Field:draw(clock)

	--self:draw

	for _, zone in pairs(self.zones) do
		zone:draw(clock)
	end
	for _, ship in pairs(self.ships) do
		ship:draw(clock)
	end
end

function Field:update(dt, clock)
	-- update ships
	for _, ship in pairs(self.ships) do
		ship:update(dt, clock)
	end

	-- update zones
	for _, zone in pairs(self.zones) do
		zone:update(dt, clock)
	end

	-- post update zones
	for _, zone in pairs(self.zones) do
		zone:postUpdate(dt, clock)
	end

	-- check for collisons
	for _, zone in pairs(self.zones) do
		if zone.isBlast then
			for _, ship in pairs(self.ships) do
				if zone:contains(ship.angle) and zone:hasEnemyPulse(ship) then
					ship:loseLife()
				end
			end
		end
	end

end

return Field
