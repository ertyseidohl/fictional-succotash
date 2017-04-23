--[[
The MIT License (MIT)

Copyright (c) 2015 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local GL_SHADER_SOURCE = [[
		const number MAX_RADIUS = 3.0;

        extern vec2 direction;
        extern number radius;
        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
        {
                vec4 c = vec4(0.0);
                for(float i = -MAX_RADIUS; i <= MAX_RADIUS; i += 1.0) {
                        if(abs(i) < radius)
                                c += Texel(texture, tc+i*direction);
                }
                return 2.0*color*c / (2.0*radius + 1.0);
        }
	]]

return {
description = "Box blur shader with support for different horizontal and vertical blur size",

new = function(self)
	self.radius_h, self.radius_v = 3, 3

	self.width, self.height = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

	self.canvas_h, self.canvas_v = love.graphics.newCanvas(width, height), love.graphics.newCanvas(width, height)
	self.shader = love.graphics.newShader(GL_SHADER_SOURCE)
	warnings = self.shader:getWarnings( )
	print("GL issues: " .. warnings)
	self.shader:send("direction",{1.0,0.0}) --Not needed but may fix some errors if the shader is used somewhere else
end,

draw = function(self, func, ...)
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}

	love.graphics.push()
	love.graphics.scale(0.5, 0.5)

	-- draw scene
	self:_render_to_canvas(self.canvas_h, func, ...)

	love.graphics.setColor(co)
	love.graphics.setShader(self.shader)

	local b = love.graphics.getBlendMode()
	love.graphics.setBlendMode('alpha', 'premultiplied')

	-- first pass (horizontal blur)
	self.shader:send('direction', {1 / self.width, 0})
	self.shader:send('radius', math.floor(self.radius_h*0.5 + .5))
	self:_render_to_canvas(self.canvas_v,
	                       love.graphics.draw, self.canvas_h, 0,0)

	-- second pass (vertical blur)
	self.shader:send('direction', {0, 1 / self.height})
	self.shader:send('radius', math.floor(self.radius_v*0.5 + .5))

	love.graphics.pop()

	love.graphics.draw(self.canvas_v, 0,0, 0, 4, 4)

	-- restore blendmode, shader and canvas
	love.graphics.setBlendMode(b)
	love.graphics.setShader(s)
end,

set = function(self, key, value)
	local sz = math.floor(assert(tonumber(value), "Not a number: "..tostring(value)) + .5)
	if key == "radius" then
		self.radius_h, self.radius_v = sz, sz
	elseif key == "radius_h" or key == "radius_v" then
		self[key] = sz
	else
		error("Unknown property: " .. tostring(key))
	end
	return self
end
}
