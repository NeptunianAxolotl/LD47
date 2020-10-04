
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
	
	function self.IsColliding(otherPos, otherRadius, isCreature, isProjectile, player, dt)
		if not ((isCreature and def.collideCreature) or (isProjectile and def.collideProjectile) or (player and def.overlapEffect)) then
			return
		end
		local collide, dist = util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius)
		if not collide then
			return
		end
		if not (player and def.overlapEffect) then
			return true
		end
		local realCollide, removeObstacle = def.overlapEffect(self, player, dist, dt)
		return realCollide, removeObstacle
	end
	
	function self.Update(Terain, dt)
		
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
