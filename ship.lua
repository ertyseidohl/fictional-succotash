local Ship = class("Ship")

function Ship:initialize(number, color, startAngle, keys, sound)
	self.number = number
	self.color = color
	self.angle = startAngle
	self.keys = keys
	self.lives = SHIP_STARTING_LIVES
	self.invincibleTimer = 0;
	self.velocity = 0

	self.aiVelocity = 0
	self.aiFire = false

	self.soundsystem = sound

end

function Ship:draw(clock)
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

	if DO_BLUR then
		local blurAmt = ((clock.quarter_count + 1) % 2)
		local blurSize = (SHIP_HEIGHT + (SHIP_BLUR_SIZE * 2)) * blurAmt

		local pointBlur = {
			x = field.center.x + (math.cos(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER - SHIP_BLUR_SIZE)),
			y = field.center.y + (math.sin(self.angle) * (field.maxRadius / 2 + SHIP_BUFFER - SHIP_BLUR_SIZE))
		}

		local rightArmBlur = {
			x = pointBlur.x + (math.cos(self.angle - SHIP_RADIAL_WIDTH) * blurSize),
			y = pointBlur.y + (math.sin(self.angle - SHIP_RADIAL_WIDTH) * blurSize),
		}

		local leftArmBlur = {
			x = pointBlur.x + (math.cos(self.angle + SHIP_RADIAL_WIDTH) * blurSize),
			y = pointBlur.y + (math.sin(self.angle + SHIP_RADIAL_WIDTH) * blurSize),
		}

		love.graphics.setColor(self.color[1], self.color[2], self.color[3], SHIP_BLUR_INTENSITY)

		love.graphics.polygon('fill', {
			leftArmBlur.x, leftArmBlur.y,
			pointBlur.x, pointBlur.y,
			rightArmBlur.x, rightArmBlur.y
		})

		local blurRadians = math.rad(5) * blurAmt
		love.graphics.setLineWidth((SHIP_LIFE_LINE_WIDTH + SHIP_BLUR_SIZE) * blurAmt)

		for i = 1, self.lives, 1 do
			love.graphics.arc(
				'line',
				'open',
				point.x,
				point.y,
				SHIP_HEIGHT + (SHIP_LIFE_LINE_BUFFER * i),
				self.angle - SHIP_LIFE_LINE_ANGLE - blurRadians,
				self.angle + SHIP_LIFE_LINE_ANGLE + blurRadians
			)
		end
	end
end

function Ship:isAlive()
	return self.lives > 0
end

function Ship:update(dt, clock, ai)

	if not self:isAlive() then
		return
	end

	if ai then
		if clock.is_on_whole then
			self.aiVelocity = math.random(3) - 2
			if math.random(10) > 6 then
				self.aiFire = true
			else
				self.aiFire = false
			end
		end
		self.velocity = self.velocity + SHIP_ACCELERATION * self.aiVelocity

		if self.aiFire then
			field:fill(dt, self)
		end
	end

	if love.keyboard.isDown(self.keys.f) or
		(joystick and joystick:isDown(self.keys.jf))
	then
		--musicsystem:fire()
		field:fill(dt, self)
	end

	if love.keyboard.isDown(self.keys.c) or
		(joystick and joystick:isDown(self.keys.jc))
	then
		self.velocity = self.velocity + SHIP_ACCELERATION
	elseif love.keyboard.isDown(self.keys.cc) or
		(joystick and joystick:isDown(self.keys.jcc))
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
		if self.lives < 1 then
			self.soundsystem:die()
		else
			self.soundsystem:hit()
		end
	end
end

return Ship
