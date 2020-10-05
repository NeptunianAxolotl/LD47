
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false

local function NewEffect(self, def)
	-- pos
	self.inFront = def.inFront or 0
	local maxLife = (def.duration == "inherit" and def.image and Resources.GetAnimationDuration(def.image)) or def.duration
	if not maxLife then
		print(maxLife, def.image, def.actual_image)
	end
	self.life = maxLife
	self.animTime = 0
	self.direction = (def.randomDirection and math.random()*2*math.pi) or 0
	
	self.pos = (def.spawnOffset and util.Add(self.pos, def.spawnOffset)) or self.pos
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		self.life = self.life - dt
		if self.life <= 0 then
			return true
		end
		
		if self.velocity then
			self.pos = util.Add(self.pos, util.Mult(dt*60, self.velocity))
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + self.inFront; f=function()
			if def.actual_image then
				Resources.DrawImage(def.actual_image, self.pos[1], self.pos[2], self.direction,
					(def.alphaScale and self.life/maxLife) or 1,
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
			else
				Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction,
					(def.alphaScale and self.life/maxLife) or 1,
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
			end
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		if def.actual_image then
			Resources.DrawAnimation(def.actual_image, self.pos[1], self.pos[2], self.direction,
					(def.alphaScale and self.life/maxLife) or 1,
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
		else
			Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction,
					(def.alphaScale and self.life/maxLife) or 1,
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
		end
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], 100)
		end
	end
	
	return self
end

return NewEffect
