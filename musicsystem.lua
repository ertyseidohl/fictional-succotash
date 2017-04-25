local MusicSystem = class("MusicSystem")

MUSIC_LAGTIME_ADJUST = 0.0005

function MusicSystem:initialize()
	self.tracka = nil
	self.trackb = nil
	self.startScreen = nil

	self.track = self.tracka
	self.inGame = false

	self.gstart = nil
	self.gover = nil

	self.hitfx = nil
	self.diefx = nil
	self.firefx = nil

	self.songTime = 0
	self.songLastTime = 0
	self.lagtime = 0.0065
end

function MusicSystem:load()
	self.tracka = love.audio.newSource("media/music/PizzaLasers.wav", "static")
	self.tracka:setLooping(true)

	self.track = self.tracka

	self.trackb = love.audio.newSource("media/music/BarcadeFrenzy.wav", "static")
	self.trackb:setLooping(true)

	self.startScreen = love.audio.newSource("media/music/ChooseYourCharacter.wav")
	self.startScreen:setLooping(true)

	self.gstart = love.audio.newSource("media/music/GETREADY.wav", "static")
	self.gover = love.audio.newSource("media/music/GAMEOVER.wav", "static")

	self.hitfx = love.audio.newSource("media/SFX/HIT.wav", "static")
	self.diefx = love.audio.newSource("media/SFX/V9KO.wav", "static")
	self.firefx = love.audio.newSource("media/SFX/SHOOT.wav", "static")
end

function MusicSystem:play()
	if self.inGame then
		love.audio.play(self.track)
	else
		love.audio.play(self.startScreen)
	end
end

function MusicSystem:hit()
	love.audio.play(self.hitfx)
end

function MusicSystem:die()
	love.audio.play(self.diefx)
end

function MusicSystem:fire()
	love.audio.play(self.firefx)
end

function MusicSystem:switchTrack()
	if self.tracka:isPlaying() then
		love.audio.stop(self.tracka)
		love.audio.play(self.trackb)
		self.track = self.trackb
	else
		love.audio.stop(self.trackb)
		love.audio.play(self.tracka)
		self.track = self.tracka
	end
end

function MusicSystem:gameOver()
	self.inGame = false
	love.audio.stop(self.track)
	love.audio.play(self.gover)
end

function MusicSystem:gameStart()
	self.inGame = true
	love.audio.stop(self.startScreen)
	love.audio.stop(self.track)
	love.audio.play(self.gstart)
end

function MusicSystem:update(dt)
	local fixup = false
	if not self.gstart:isPlaying() and not self.gover:isPlaying() and not self.track:isPlaying() then
		self:play()
		fixup = true
	elseif self.gstart:isPlaying() or self.gover:isPlaying() then
		fixup = true
	end

	if not fixup then
		local musicTime = self.track:tell("seconds");
		if musicTime ~= self.songLastTime then
			-- Do easing
			if musicTime < self.songLastTime then
				musicTime = musicTime + (self.track:getDuration("seconds") - self.songLastTime) + self.songTime
			end
			self.songTime = (self.songTime + musicTime) / 2
			self.songLastTime = musicTime
		else
			self.songTime = self.songTime + dt
		end
	else
		self.songTime = 0
		self.songLastTime = 0
	end

	return self.songTime + self.lagtime
end

function MusicSystem:adjustUp()
	self.lagtime = self.lagtime + MUSIC_LAGTIME_ADJUST
	print("Lag = " .. string.format("%.4f",self.lagtime))
end

function MusicSystem:adjustDown()
	self.lagtime = self.lagtime - MUSIC_LAGTIME_ADJUST
	print("Lag = " .. string.format("%.4f",self.lagtime))
end

return MusicSystem
