local Field = class('Field')

local Zone = require 'zone'
local Ship = require 'ship'
local Devil = require 'devil'

local LINE_WIDTH = 1
local RADIAL_WIDTH_HALF = (math.pi * 2 / 32) / 2
local FIELD_SEGMENTS = 64

local GRID_COLOR = {128, 0, 128}

function Field:initialize(rings, slices, maxRadius)
	self.rings = rings
	self.slices = slices
	self.maxRadius = maxRadius
	self.zones = {}
	self.ships = {}
	self.center = {
		x = WIDTH / 2,
		y = HEIGHT / 2
	}
	self.devil = Devil:new(self)
	self.radiusIncrement = (self.maxRadius / self.rings) * 0.5
	self.radialWidth = (2 * math.pi) / self.slices
	self:generateZones()
end

function Field:setPlayers(players)
	--players is an array of 4 bools
	if players[1] then
		table.insert(self.ships, Ship:new(1, PLAYER_COLORS[1], RADIAL_WIDTH_HALF, {cc = 'z', c = 'x', f = 's'}))
	end
	if players[2] then
		table.insert(self.ships, Ship:new(2, PLAYER_COLORS[2], math.pi + RADIAL_WIDTH_HALF, {cc = 'c', c = 'v', f = 'f'}))
	end
	if players[3] then
		table.insert(self.ships, Ship:new(3, PLAYER_COLORS[3], math.pi * 0.5 + RADIAL_WIDTH_HALF, {cc = 'b', c = 'n', f = 'h'}))
	end
	if players[4] then
		table.insert(self.ships, Ship:new(4, PLAYER_COLORS[4], math.pi * 1.5 + RADIAL_WIDTH_HALF, {cc = 'm', c = ',', f = 'k'}))
	end
end

function Field:killPlayers()
	for i = 1, #self.ships, 1 do
		self.ships[i].lives = 0
	end
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

function Field:fill(dt, ship, fromInner)
	local zone = nil
	if (fromInner) then
		zone = self:getZone(INNER_RINGS, math.ceil(ship.angle / self.radialWidth))
	else
		zone = self:getZone(self.rings, math.ceil(ship.angle / self.radialWidth))
	end
	zone:fill(dt, ship, fromInner)
end

function Field:draw(clock)
	love.graphics.setLineWidth(LINE_WIDTH)
	self:drawCircles(clock)

	self.devil:draw(clock)

	for _, zone in pairs(self.zones) do
		zone:draw(clock)
	end
	for _, ship in pairs(self.ships) do
		ship:draw(clock)
	end
end

function Field:drawCircles(clock)
	for ring = math.max(INNER_RINGS - 1, 1), self.rings, 1 do
		local zoneRing = self:getZone(ring, 1)
		if (ring - clock.eighth_count) % 4 == 0 then
			love.graphics.setColor(GRID_COLOR[1], GRID_COLOR[2], GRID_COLOR[3], 255 - (self.rings - ring) * 10)
			love.graphics.circle('line', self.center.x, self.center.y, zoneRing.outerRadius, FIELD_SEGMENTS)
		end
	end
end

function Field:update(dt, clock)
	-- update devil
	self.devil:update(dt, clock)

	-- update ships
	local aliveShips = 0
	for _, ship in pairs(self.ships) do
		ship:update(dt, clock)
		if ship:isAlive() then
			aliveShips = aliveShips + 1
		end
	end
	if aliveShips == 0 then
		endGame()
		return
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
