local Devil = class('Devil')

local Hand = require 'hand'

local DEVIL_RADIUS = 20
local DEVIL_LINE_SEGMENTS = 20
local DEVIL_COLOR = {127, 0, 127, 255}

function Devil:initialize(field)
	self.center = field.center

	self.color = DEVIL_COLOR

	self.hands = {
		-- todo more hands
		Hand:new(self, math.deg(90)),
		Hand:new(self, math.deg(180))
	}
	self.handsCount = 2
	self.handTargets = {}

	self.handPositionOffset = 0

	self.handFormationMap = {
		even = evenlySpaced,
		unison = sameDirection,
		fan = fanOut,
	}

	self.handFormationConfig = {
		snap = {
			beats = 4,
			nextState = 'snap',
			formationStrategy = 'change',
			formations = {
				'even', 'unison', 'fan'
			},
			formationsLength = 3,
		},
		action = {
			beats = 4,
			nextState = 'snap',
		}
	}

	self.handState = 'snap'
	self.handBeatClock = 0
	self.handFormation = 'none'
	self.handOffset = 0
end

function Devil:update(dt, clock)
	self:handAI(clock)
	for _, hand in pairs(self.hands) do
		hand:update(dt, clock)
	end
end

function Devil:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.circle('fill', self.center.x, self.center.y, DEVIL_RADIUS, DEVIL_LINE_SEGMENTS)

	for _, hand in pairs(self.hands) do
		hand:draw()
	end
end

function Devil:handAI(clock)
	local changeState = false
	if clock.is_on_quarter then
		self.handBeatClock = self.handBeatClock + 1
	end

	if self.handBeatClock == self.handFormationConfig[self.handState].beats then
		self.handState = self.handFormationConfig[self.handState].nextState
		self.handBeatClock = 0

		self:changeFormation()
		changeState = true
	end
end

function Devil:changeFormation()
	local config = self.handFormationConfig[self.handState]
	if config.formationStrategy == 'change' then
		self.handFormation = config.formations[math.random(config.formationsLength)]
		self.handTargets = self.handFormationMap[self.handFormation](self.handsCount, field.slices)
	end
end

function Devil:moveHands()
	for i = 1, self.handCount, 1 do

		local targetSlice= (self.handTargets[i] + self.handPositionOffset % field.slices) + 1

	end
end


function evenlySpaced(numHands, numSlices)

	local increment = math.floor(numSlices / numHands)
	local spacing = {}
	for i = 0, numHands - 1, 1 do
		table.insert(spacing, (increment * i) + 1)
	end
	return spacing

end

function sameDirection(numHands, numSlices)
	local spacing = {}
	for i = 0, numHands - 1, 1 do
		table.insert(spacing, 1)
	end
	return spacing
end

function fanOut(numHands, numSlices)
	local spacing = {}
	if numHands % 2 == 1 then
		spacing = {1}
		for i = 1, math.floor(numHands / 2), 1 do
			table.insert(spacing, i * 2)
			table.insert(spacing, i * -2)
		end
	else
		for i = 1, math.floor(numHands / 2), 1 do
			table.insert(spacing, i * 2)
			table.insert(spacing, i * -2)
		end
	end
	return spacing
end

return Devil
