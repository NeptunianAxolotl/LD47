
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = true

local function NewCreature(self, def)
	-- pos
	self.health = def.health + math.random()*def.healthRange
	self.direction = 0
	
	function self.GetPhysics()
		return self.pos, def.radius
	end
	
	function self.IsColliding(otherPos, otherRadius, otherCreatureIndex, isProjectile, player, dt)
		if otherCreatureIndex and otherCreatureIndex >= self.index then
			return
		end
		return util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius)
	end
	
	function self.Update(Terrain, Enemies, player, dt)
		if def.updateFunc then
			def.updateFunc(self, def, Terrain, Enemies, player, dt)
		end
	end
	
	function self.AddPosition(posToAdd)
		self.pos = util.Add(self.pos, posToAdd)
	end
	
	function self.Draw()
		Resources.DrawIsoImage(def.imageName, self.pos[1], self.pos[2], self.direction)
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	return self
end

return NewCreature
