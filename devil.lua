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
end

function Devil:update(dt, clock)
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

return Devil
