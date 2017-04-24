local Ship = class("Ship")

function Ship:initialize(number, color, startAngle, keys)
	self.number = number
	self.color = color
	self.angle = startAngle
	self.keys = keys
	self.lives = SHIP_STARTING_LIVES
	self.invincibleTimer = 0;
	self.velocity = 0
end

function Ship:draw()
	if not self:isAlive() then
		return
	end
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

	if self.invincibleTimer > 0 and self.invincibleTimer % 2 == 0 then
		love.graphics.setColor({255, 255, 255, 255})
	else
		love.graphics.setColor(unpack(self.color))
	end

	love.graphics.polygon('fill', {
		leftArm.x, leftArm.y,
		point.x, point.y,
		rightArm.x, rightArm.y
	})

	love.graphics.setLineWidth(SHIP_LIFE_LINE_WIDTH)
	for i = 1, self.lives, 1 do
		love.graphics.arc(
			'line',
			'open',
			point.x,
			point.y,
			SHIP_HEIGHT + (SHIP_LIFE_LINE_BUFFER * i),
			self.angle - SHIP_LIFE_LINE_ANGLE,
			self.angle + SHIP_LIFE_LINE_ANGLE
		)
	end
end

function Ship:isAlive()
	return self.lives > 0
end

function Ship:update(dt, clock)
	if not self:isAlive() then
		return
	end

	if love.keyboard.isDown(self.keys.f) or
		joystcik.isDown(self.keys.jf)
	then
		field:fill(dt, self)
	end

	if love.keyboard.isDown(self.keys.c) or
		joystick.isDown(self.keys.jc)
	then
		self.velocity = self.velocity + SHIP_ACCELERATION
	elseif love.keyboard.isDown(self.keys.cc) or
		joystick.isDown(self.keys.jcc)
	then
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

	if self.invincibleTimer > 0 and clock.is_on_eighth then
		self.invincibleTimer = self.invincibleTimer - 1
	end
end

function Ship:loseLife()
	if self.invincibleTimer == 0 then
		self.lives = self.lives - 1
		self.invincibleTimer = SHIP_INVINCIBLE_TIME
	end
end

return Ship
