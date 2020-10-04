
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = true

local function NewObstacle(self, def, rng)
	-- pos
	self.health = def.health + rng:random()*def.healthRange
	
	function self.GetPhysics()
		return self.pos, def.radius
	end
	
	function self.IsColliding(otherPos, otherRadius, isCreature, projectile, player, dt)
		if not ((isCreature and def.collideCreature) or (projectile and def.collideProjectile) or (player and def.overlapEffect)) then
			return
		end
		local collide, distSq = util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius)
		if not collide then
			return
		end
        -- player collision
		if (player and def.overlapEffect) then
            local realCollide, removeObstacle = def.overlapEffect(self, player, distSq, dt)
            return realCollide, removeObstacle
		end
        -- projectile collision
        if (projectile and def.projectileEffect) then
            local realCollide, removeObstacle = def.projectileEffect(self, projectile, distSq, dt)
            return realCollide, removeObstacle
        end
        return true
	end
	
	function self.IsBlockingPlacement(otherPos, otherDef)
		if util.IntersectingCircles(self.pos, def.placeBlockRadius, otherPos, otherDef.placeRadius) then
			return true
		end
	end
	
	function self.Draw()
		Resources.DrawImage(def.imageName, self.pos[1], self.pos[2])
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	return self
end

return NewObstacle
