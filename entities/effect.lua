
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false

local function NewEffect(self, def)
	-- pos
	self.inFront = def.inFront or 0
	local maxLife = (def.duration == "inherit" and Resources.GetAnimationDuration(def.image)) or def.duration
	self.life = maxLife
	self.animTime = 0
	
	self.pos = (def.spawnOffset and util.Add(self.pos, def.spawnOffset)) or self.pos
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		self.life = self.life - dt
		if self.life <= 0 then
			return true
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + self.inFront; f=function()
			Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction, (def.alphaScale and self.life/maxLife) or 1, self.scale, def.color)
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction, (def.alphaScale and self.life/maxLife) or 1, self.scale, def.color)
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], 100)
		end
	end
	
	return self
end

return NewEffect
