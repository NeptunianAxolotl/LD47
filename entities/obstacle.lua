
local util = require("include/util")
local Resources = require("resourceHandler")
local EffectsHandler = require("effectsHandler")

local DRAW_DEBUG = true

local function NewObstacle(self, def, rng, chunkX, chunkY, chunkWidth, chunkHeight)
	-- pos
	self.health = def.health + rng:random()*def.healthRange
	self.sizeMult = self.sizeMult or (def.minSize + rng:random()*(def.maxSize - def.minSize))
	
	self.placeBlocker = def.placeBlock and {
		util.Add(self.pos, util.Mult(self.sizeMult, def.placeBlock[1])),
		self.sizeMult*def.placeBlock[2]
	}
	
	if def.chunkEdgePads and chunkX then
		local pad = def.chunkEdgePads
		if util.PosInRectangle(self.pos, chunkX + pad[1], chunkY + pad[2], chunkWidth - (pad[1] + pad[3]), chunkHeight - (pad[1] + pad[3])) then
			self.nearChunkEdge = true
		end
	end
	
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
	
	function self.IsBlockingPlacement(otherPos, otherDef, placeBlockPos, placeBlockRadius)
		if placeBlockPos and def.blockedByTrees then
			if util.PosInCircle(self.pos, placeBlockPos, placeBlockRadius) then
				--EffectsHandler.Spawn("debug_explode", self.pos)
				return true
			end
		end
		if otherDef.blockedByTrees and self.placeBlocker then
			if util.PosInCircle(otherPos, self.placeBlocker[1], self.placeBlocker[2]) then
				--EffectsHandler.Spawn("debug_explode", self.pos)
				return true
			end
		end
		if util.IntersectingCircles(self.pos, def.placeBlockRadius, otherPos, otherDef.placeRadius) then
			return true
		end
	end
	
	function self.Update(dt)
		if def.spellName then
			self.animDt = Resources.UpdateAnimation(def.spellAnim, self.animDt or 0, dt)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + (def.drawInFront or 0); f=function()
			if def.spellName then
				Resources.DrawAnimation(def.spellAnim, self.pos[1], self.pos[2], self.animDt or 0, false, 0.8, (def.scale or 1)*self.sizeMult)
			end
			Resources.DrawImage(self.imageOverride or def.imageName, self.pos[1], self.pos[2], false, false, (def.scale or 1)*self.sizeMult)
		end})
		if DRAW_DEBUG then
			drawQueue:push({y=2^20; f=function() love.graphics.circle('line',self.pos[1], self.pos[2], def.radius*self.sizeMult) end})
			if self.placeBlocker then
				drawQueue:push({y=2^20; f=function() love.graphics.circle('line',self.placeBlocker[1][1], self.placeBlocker[1][2], self.placeBlocker[2]) end})
			end
		end
	end
	
	return self
end

return NewObstacle
