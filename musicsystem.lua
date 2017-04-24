local MusicSystem = class("MusicSystem")

MUSIC_LAGTIME_ADJUST = 0.0005

function MusicSystem:initialize()
	self.tracka = love.audio.newSource("media/music/PizzaLasers.wav", "static")
	self.tracka:setLooping(true)

	self.trackb = love.audio.newSource("media/music/BarcadeFrenzy.wav", "static")
	self.trackb:setLooping(true)

	self.track = self.tracka

	self.gstart = love.audio.newSource("media/music/GETREADY.wav", "static")
	self.gover = love.audio.newSource("media/music/GAMEOVER.wav", "static")

	self.songTime = 0
	self.songLastTime = 0
	self.lagtime = 0.0065
end

function MusicSystem:play()
	love.audio.play(self.track)
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
	love.audio.play(self.gover)
end

function MusicSystem:gameStart()
	love.audio.play(self.gstart)
end

function MusicSystem:update(dt)
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