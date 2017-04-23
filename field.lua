local Field = class('Field')

local Zone = require 'zone'
local Ship = require 'ship'
local Devil = require 'devil'

local LINE_WIDTH = 1
local RADIAL_WIDTH_HALF = (math.pi * 2 / 32) / 2

local GRID_COLORS = {
	{255, 178, 174}, -- pastel red
	{225, 239, 255}, -- pastel blue
	{239, 255, 225}, -- pastel green
	{254, 255, 225}, -- pastel yellow
}

function Field:initialize(rings, slices, maxRadius)
	self.rings = rings
	self.slices = slices
	self.maxRadius = maxRadius
	self.zones = {}
	self.ships = {
		Ship:new(1, {255,0,0,255}, RADIAL_WIDTH_HALF, {cc = 'z', c = 'x', f = 's'}),
		Ship:new(2, {0,0,255,255}, math.pi + RADIAL_WIDTH_HALF, {cc = 'c', c = 'v', f = 'f'}),
		--Ship:new(3, {0,255,0,255}, math.pi * 0.5 + RADIAL_WIDTH_HALF, {cc = 'b', c = 'n', f = 'h'}),
		Ship:new(4, {255,255,0,255}, math.pi * 1.5 + RADIAL_WIDTH_HALF, {cc = 'm', c = ',', f = 'k'})
	}
	self.center = {
		x = WIDTH / 2,
		y = HEIGHT / 2
	}
	self.devil = Devil:new(self)
	self.radiusIncrement = (self.maxRadius / self.rings) * 0.5
	self.radialWidth = (2 * math.pi) / self.slices
	self:generateZones()
end

function Field:generateZones()
	for ring = 1, self.rings, 1 do
		for slice = 1, self.slices, 1 do
			--love.event.quit()
			table.insert(self.zones, Zone:new(
				ring,
				slice,
				self.center,
				(slice - 1) * self.radialWidth,
				(slice) * self.radialWidth,
				(ring - 1) * self.radiusIncrement,
				(ring) * self.radiusIncrement,
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
	love.graphics.setLineWidth(LINE_WIDTH)
	self:drawRadials(clock)
	self:drawCircles(clock)

	self.devil:draw(clock)

	for _, zone in pairs(self.zones) do
		zone:draw(clock)
	end
	for _, ship in pairs(self.ships) do
		ship:draw(clock)
	end
end

function Field:drawRadials(clock)

	local flash = 100
	-- if clock.sixteenth_count % 4 == 0 and clock.sixteenth_count % 8 == 0 then
	-- 	flash = 140
	-- end

	for slice = 1, self.slices, 1 do
		local outerZone = self:getZone(self.rings, slice)
		local innerZone = self:getZone(INNER_RINGS, slice)
		love.graphics.setColor(255, 255, 255, flash)
		love.graphics.line(innerZone.right.inner.x, innerZone.right.inner.y, outerZone.right.outer.x, outerZone.right.outer.y)
	end

end

function Field:drawCircles(clock)
    for ring = math.max(INNER_RINGS - 1, 1), self.rings, 1 do
    	local zoneRing = self:getZone(ring, 1)
    	local color = GRID_COLORS[((-clock.eighth_count + ring) % 4) + 1]
    	color[4] = 255 - (self.rings - ring) * 10
    	love.graphics.setColor(unpack(color))
    	love.graphics.circle('line', self.center.x, self.center.y, zoneRing.outerRadius, SEGMENTS)
    end
end

function Field:update(dt, clock)
	-- update devil
	self.devil:update(dt, clock)

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
		if zone.isBlast and zone:getPulse() ~= nil then
			for _, ship in pairs(self.ships) do
				if zone:contains(ship.angle) then
					ship:loseLife()
				end
			end
		end
	end
end

return Field
