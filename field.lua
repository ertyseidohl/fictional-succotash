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
	self.ships = {nil, nil, nil, nil}
	self.center = {
		x = WIDTH / 2,
		y = HEIGHT / 2
	}
	self.devil = Devil:new(self)
	self.radiusIncrement = (self.maxRadius / self.rings) * 0.5
	self.radialWidth = (2 * math.pi) / self.slices
	self:generateZones()
end

function Field:addShip(player)
	if player == 1 then
		self.ships[1] = Ship:new(1, PLAYER_COLORS[1], RADIAL_WIDTH_HALF, PLAYER_KEYS[1])
	end
	if player == 2 then
		self.ships[2] = Ship:new(2, PLAYER_COLORS[2], math.pi + RADIAL_WIDTH_HALF, PLAYER_KEYS[2])
	end
	if player == 3 then
		self.ships[3] = Ship:new(3, PLAYER_COLORS[3], math.pi * 0.5 + RADIAL_WIDTH_HALF, PLAYER_KEYS[3])
	end
	if player == 4 then
		self.ships[4] = Ship:new(4, PLAYER_COLORS[4], math.pi * 1.5 + RADIAL_WIDTH_HALF, PLAYER_KEYS[4])
	end
end

function Field:buildShips(players)
	--players is an array of 4 bools
	for i = 1, 4, 1 do
		if players[i] == PLAYER_STATE_ALIVE then
			self:addShip(i)
		end
	end
end

function Field:killPlayers()
	-- for debugging
	for i = 1, 4, 1 do
		if self.ships[i] then
			self.ships[i].lives = 0
			playerSystem:notifyOfDeath(i)
		end
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


function Field:fillZone(dt, ring, slice, ship, fromInner)
	self:getZone(ring, slice):fill(dt, ship, fromInner)
end

function Field:fill(dt, ship, fromInner)
	local zone = nil
	if (fromInner) then
		zone = self:getZone(INNER_RINGS - 1, math.ceil(ship.angle / self.radialWidth))
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
			love.graphics.setLineWidth(RING_LINE_WIDTH)
			love.graphics.setColor(GRID_COLOR[1], GRID_COLOR[2], GRID_COLOR[3], 255 - (self.rings - ring) * 10)
			love.graphics.circle('line', self.center.x, self.center.y, zoneRing.outerRadius, FIELD_SEGMENTS)

			if DO_BLUR then
				for i = 1, 4, 1 do
					love.graphics.setColor({GRID_COLOR[1], GRID_COLOR[2], GRID_COLOR[3], RING_BLUR_INTENSITY - (self.rings - ring) * 10})
					love.graphics.setLineWidth(RING_BLUR_SIZE * i)
					love.graphics.circle('line', self.center.x, self.center.y, zoneRing.outerRadius, FIELD_SEGMENTS)
				end
			end
		end
	end
end

function Field:update(dt, clock)
	-- update devil
	self.devil:update(dt, clock)

	-- update ships
	for i = 1, 4, 1 do
		if self.ships[i] and playerSystem.playerStates[i] == PLAYER_STATE_ALIVE then
			self.ships[i]:update(dt, clock)
			if not self.ships[i]:isAlive() then
				playerSystem:notifyOfDeath(i)
			end
		end
	end
	if playerSystem:getAlivePlayerCount() == 0 then
		endGame()
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
			for i = 1, 4, 1 do
				if self.ships[i] and
					zone:contains(self.ships[i].angle)
				then
					self.ships[i]:loseLife()
				end
			end
		end
	end

	--  studying the field for scoring and ai
	local slice_count = 0
	local player_slice_counts = {0, 0, 0, 0}
	local overfilledSlice = false
	local overfilledSliceCount = 0
	if clock.is_on_quarter then
		for i = 1, self.slices, 1 do
			pulse = self:getZone(INNER_RINGS, i):getPulse()
			local ringCount = 0

			if pulse ~= nil and pulse.ship.number < 5 then
				playerSystem:incrementScore(pulse.ship.number, SCORE_CENTER_RING)
				slice_count = slice_count + 1
				player_slice_counts[pulse.ship.number] = player_slice_counts[pulse.ship.number] + 1
				ringCount = 1
			end

			for j = INNER_RINGS + 1, self.rings, 1 do
				pulse = self:getZone(INNER_RINGS, i):getPulse()
				if pulse ~= nil and pulse.ship.number < 5 then
					ringCount = ringCount + 1
				end
			end

			if ringCount > math.min(self.rings / 2, overfilledSliceCount) then
				overfilledSlice = i
				overfilledSliceCount = ringCount
			end
		end
	end

	if overfilledSliceCount > 0 then
		self.devil:prepBeam(overfilledSlice)
	end

	if clock.is_on_whole and slice_count == self.slices then
		for i = 1, 4, 1 do
			playerSystem:incrementScore(i, SCORE_FULL_RING * player_slice_counts[i])
		end
	end
end

function Field:clear()
	self.zones = {}
	self:generateZones()
end

function Field:makeShipInvincible(i)
	if self.ships[i] ~= nil then
		self.ships[i].invincibleTimer = SHIP_INVINCIBLE_TIME
	end
end

return Field
