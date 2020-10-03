
local util = require("include/util")
local Resources = require("resourceHandler")

local function NewObstacle(self, def)
	-- pos
	self.health = def.health + math.random()*def.healthRange
	
	
	function self.IsColliding(otherPos, otherRadius)
		if util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius) then
			return true
		end
	end
	
	function self.IsBlockingPlacement(otherPos, otherDef)
		if util.IntersectingCircles(self.pos, def.placeBlockRadius, otherPos, otherDef.placeRadius) then
			return true
		end
	end
	
	function self.Draw()
		Resources.DrawImage(def.imageName, self.pos[1], self.pos[2])
		love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
	end
	
	return self
end

return NewObstacle
