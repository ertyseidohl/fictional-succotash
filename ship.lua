local Ship = class("Ship")

SHIP_RADIAL_WIDTH = math.rad(25);
SHIP_HEIGHT = 25;
SHIP_BUFFER = 10;

SHIP_ACCELERATION = 0.0025;
SHIP_FRICTION = 0.90;
SHIP_MAX_VELOCITY = 0.05;

function Ship:initialize(number, color, startAngle)
	self.number = number
	self.color = color
	self.angle = startAngle

	self.velocity = 0
end

function Ship:draw()
	local point = {
		x = field.center.x + (math.cos(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER)),
		y = field.center.y + (math.sin(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER))
	}

	local leftArm = {
		x = point.x + (math.cos(self.angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		y = point.y + (math.sin(self.angle + SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
	}

	local rightArm = {
		x = point.x + (math.cos(self.angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
		y = point.y + (math.sin(self.angle - SHIP_RADIAL_WIDTH) * SHIP_HEIGHT),
	}

	love.graphics.setColor(unpack(self.color))
	love.graphics.polygon('fill', {
		leftArm.x, leftArm.y,
		point.x, point.y,
		rightArm.x, rightArm.y
	})
end

function Ship:update(dt)

	-- TODO button press
	if self.number == 1 then
		field:fill(dt, self)
	end

	if love.keyboard.isDown('z') then
		self.velocity = self.velocity + SHIP_ACCELERATION
	elseif love.keyboard.isDown('x') then
		self.velocity = self.velocity - SHIP_ACCELERATION
	else
		self.velocity = self.velocity * SHIP_FRICTION
	end

	if self.velocity > SHIP_MAX_VELOCITY then
		self.velocity = SHIP_MAX_VELOCITY
	elseif self.velocity < -1 * SHIP_MAX_VELOCITY then
		self.velocity = -1 * SHIP_MAX_VELOCITY
	end

	self.angle = (self.angle + self.velocity) % (math.pi*2)
end

return Ship
