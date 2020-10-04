
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
        return true
	end
    
    function self.ProjectileImpact(projEffect)
        if projEffect and def.projectileCalc then
            self.health = self.health - def.projectileCalc(projEffect)
        end
    end
	
	function self.IsBlockingPlacement(otherPos, otherDef)
		if util.IntersectingCircles(self.pos, def.placeBlockRadius, otherPos, otherDef.placeRadius) then
			return true
		end
	end
    
	function self.Draw(drawQueue)
		
		drawQueue:push({y=self.pos[2]; f=function() Resources.DrawImage(def.imageName, self.pos[1], self.pos[2]) end})
		if DRAW_DEBUG then
			drawQueue:push({y=2^20; f=function() love.graphics.circle('line',self.pos[1], self.pos[2], def.radius) end})
		end
	end
	
	return self
end

return NewObstacle
