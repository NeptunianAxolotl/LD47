
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false

local function NewObstacle(self, def, rng)
	-- pos
	self.health = def.health + rng:random()*def.healthRange
	self.sizeMult = def.minSize + rng:random()*(def.maxSize - def.minSize)
	
	function self.GetPhysics()
		return self.pos, def.radius*self.sizeMult
	end
	
	function self.IsColliding(otherPos, otherRadius, isCreature, isProjectile, player, dt)
		if not ((isCreature and def.collideCreature) or (isProjectile and def.collideProjectile) or (player and (def.overlapEffect or def.spellName))) then
			return
		end
		local collide, distSq = util.IntersectingCircles(self.pos, def.radius*self.sizeMult, otherPos, otherRadius)
		if not collide then
			return
		end
		if player and def.spellName then
			player.PickupSpell(def.spellName, self.spellLevel or 1)
			return false, true
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
	
	function self.Update(dt)
		if def.spellName then
			self.animDt = Resources.UpdateAnimation("spell_anim", self.animDt or 0, dt)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + (def.drawInFront or 0); f=function()
			if def.spellName then
				Resources.DrawAnimation("spell_anim", self.pos[1], self.pos[2], self.animDt or 0, false, 0.8, (def.scale or 1)*self.sizeMult)
			end
			Resources.DrawImage(self.imageOverride or def.imageName, self.pos[1], self.pos[2], false, false, (def.scale or 1)*self.sizeMult)
		end})
		if DRAW_DEBUG then
			drawQueue:push({y=2^20; f=function() love.graphics.circle('line',self.pos[1], self.pos[2], def.radius*self.sizeMult) end})
		end
	end
	
	return self
end

return NewObstacle
