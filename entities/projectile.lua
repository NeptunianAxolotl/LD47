
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false


local function NewCreature(self, def)
	-- pos
	-- velocity
	self.direction = util.Angle(self.velocity)
	self.animTime = 0
	
	function self.GetPhysics()
		return self.pos, def.radius
	end
	
	function self.IsColliding(otherPos, otherRadius, dt)
		return util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius)
	end

	function self.Update(Terrain, Enemies, player, dt)
		if def.updateFunc then
			def.updateFunc(self, def, Terrain, Enemies, player, dt)
		end
		
		self.animTime = Resources.UpdateAnimation(def.imageName, self.animTime, dt)
		
		self.pos = util.Add(self.pos, util.Mult(dt*60, self.velocity))
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + 120; f=function()
			Resources.DrawAnimation(def.imageName, self.pos[1], self.pos[2], self.animTime, self.direction)
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	return self
end

return NewCreature
