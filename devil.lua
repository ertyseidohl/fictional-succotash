local Devil = class('Devil')

local Hand = require 'hand'

function Devil:initialize(field)
	self.center = field.center
	self.color = DEVIL_COLOR
	self.hands = {
		-- todo more hands
		Hand:new(self, math.rad(90)),
		Hand:new(self, math.rad(180)),
		Hand:new(self, math.rad(270)),
		Hand:new(self, math.rad(0)),
		Hand:new(self, math.rad(90)),
	}
	self.handCount = 5
	self.handTargets = {0, 0, 0, 0, 0}

	self.handPositionOffset = 0

	self.handFormationMap = {
		even = evenlySpaced,
		unison = sameDirection,
		fan = fanOut,
	}

	self.handAttackMap = {
		none = noneAttack,
		fire = fireAttack
	}

	self.handFormationConfig = {
		snap = {
			beats = 4,
			nextState = 'action',
			formationStrategy = 'change',
			formations = {
				'even', 'unison', 'fan'
			},
			formationsLength = 3,
			attackStrategy = 'none',
		},
		action = {
			beats = 4,
			nextState = 'snap',
			formationStrategy = 'inherit',
			attackStrategy = 'change',
			attacks = {
				'fire'
			},
			attacksLength = 1
		}
	}

	self.handState = 'snap'
	self.handBeatClock = 0
	self.handFormation = 'none'
	self.rotationVelocity = 1
	self.handAttack = 'none'
end

function Devil:update(dt, clock)
	self:handAI(clock)
	for _, hand in pairs(self.hands) do
		hand:update(dt, clock)
	end
end

function Devil:draw()
	love.graphics.setColor(unpack(DEVIL_COLOR))
	love.graphics.circle('fill', self.center.x, self.center.y, DEVIL_RADIUS, DEVIL_LINE_SEGMENTS)

	for _, hand in pairs(self.hands) do
		hand:draw()
	end
end

function Devil:handAI(clock)
	local changeState = false

	if clock.is_on_half then
		self.handPositionOffset = self.handPositionOffset + self.rotationVelocity
		if clock.half_count % 2 == 0 then
			self.rotationVelocity = math.random(5) - 3
		end
	end

	if clock.is_on_quarter then
		self.handBeatClock = self.handBeatClock + 1
	end

	if self.handBeatClock == self.handFormationConfig[self.handState].beats then
		self.handState = self.handFormationConfig[self.handState].nextState
		self.handBeatClock = 0

		self:changeFormation()
		self:changeAttack()
		changeState = true
	end

	self:moveHands(clock)
	self:attackHands(clock)
end

function Devil:changeFormation()
	local config = self.handFormationConfig[self.handState]
	if config.formationStrategy == 'change' then
		self.handFormation = config.formations[math.random(config.formationsLength)]
		local targetSlices = self.handFormationMap[self.handFormation](self.handCount, field.slices)

		self.handTargets = {}
		for _, slice in pairs(targetSlices) do
			local targetSlice = (slice + self.handPositionOffset % field.slices) + 1
			table.insert(self.handTargets, 2 * math.pi * targetSlice / field.slices)
		end
	end
end

function Devil:changeAttack()
	local config = self.handFormationConfig[self.handState]
	if config.attackStrategy == 'change' then
		self.handAttack = config.attacks[math.random(config.attacksLength)]
	else
		self.handAttack = 'none'
	end
end


function Devil:moveHands(clock)
	local radialWidth = (math.pi * 2 / field.slices)
	if clock.is_on_sixteenth then
		for i = 1, self.handCount, 1 do
			local hand = self.hands[i]
			local targetAngle = self.handTargets[i]

			local moveFactor = .5
			if math.abs(hand.angle - targetAngle) < radialWidth then
				moveFactor = .125
			elseif math.abs(hand.angle - targetAngle) < radialWidth / 2 then
				moveFactor = 0
			end

			if hand.angle > targetAngle then
				hand.angle = hand.angle - radialWidth * moveFactor
			else
				hand.angle = hand.angle + radialWidth * moveFactor
			end
		end
	end
end

function Devil:attackHands(clock)
	for _, hand in pairs(self.hands) do
		--print(self.handAttack)
		self.handAttackMap[self.handAttack](clock, hand)
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


--atacks

function noneAttack(hand)

end

function fireAttack(clock, hand)
	if clock.is_on_quarter then
		hand:fire()
	end
end

return Devil
