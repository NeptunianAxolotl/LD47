
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false

local function NewCreature(self, def)
	-- pos
	self.inFront = def.inFront or 0
	self.life = (def.duration == "inherit" and Resources.GetAnimationDuration(def.image)) or def.duration
	self.animTime = 0
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		self.life = self.life - dt
		if self.life <= 0 then
			return true
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + self.inFront; f=function()
			Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction)
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction)
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], 100)
		end
	end
	
	return self
end

return NewCreature
