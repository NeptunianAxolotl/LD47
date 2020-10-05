
local util = require("include/util")
local Resources = require("resourceHandler")
local EffectHandler = require("effectsHandler")

local DRAW_DEBUG = false

local function NewProjectile(self, def)
	-- pos
	-- velocity
	self.direction = util.Angle(self.velocity)
	self.animTime = 0
	self.life = def.life
	
	function self.GetPhysics()
		return self.pos, def.radius
	end
	
	function self.IsColliding(otherPos, otherRadius, dt)
		return util.IntersectingCircles(self.pos, def.radius, otherPos, otherRadius)
	end

	function self.Update(Terrain, Enemies, player, dt)
		if self.toKill then
			if def.onKill and not self.noExplode then
				def.onKill(self, def, Terrain, Enemies, player, dt)
			end
			if def.hitEffect then
				EffectHandler.Spawn(def.hitEffect, self.pos)
			end
			return true
		end
		
		if def.updateFunc then
			def.updateFunc(self, def, Terrain, Enemies, player, dt)
		end
		
		self.life = self.life - dt
		if self.life < 0 then
			if def.onKill then
				def.onKill(self, def, Terrain, Enemies, player, dt)
			end
			return true
		end
		
		local obstacle = (not self.ignoreTerrain) and Terrain.GetTerrainCollision(self.pos, def.radius, false, true, false, dt)
		if obstacle then
			if def.onKill then
				def.onKill(self, def, Terrain, Enemies, player, dt)
			end
			if def.hitEffect then
				EffectHandler.Spawn(def.hitEffect, self.pos)
			end
			return true
		end
		
		if player.IsColliding(self.pos, def.radius) then
			if def.damage then
				player.ModifyHealth(def.damage)
			end
			if def.onKill then
				def.onKill(self, def, Terrain, Enemies, player, dt)
			end
			if def.hitEffect then
				EffectHandler.Spawn(def.hitEffect, self.pos)
			end
			return true
		end
		
		if def.animationName or def.isoAnimationName then
			self.animTime = Resources.UpdateAnimation(def.animationName or def.isoAnimationName, self.animTime, dt)
		end
		
		self.pos = util.Add(self.pos, util.Mult(dt*60, self.velocity))
	end
	
	function self.Kill(noExplode)
		self.toKill = true
		self.noExplode = noExplode
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2] + 120; f=function()
			if def.animationName then
				Resources.DrawAnimation(def.animationName, self.pos[1], self.pos[2], self.animTime or 0, self.direction)
			elseif def.isoAnimationName then
				Resources.DrawIsoAnimation(def.isoAnimationName, self.pos[1], self.pos[2], self.animTime or 0, self.direction)
			elseif def.imageName then
				Resources.DrawImage(def.imageName, self.pos[1], self.pos[2], self.direction)
			else
				Resources.DrawIsoImage(def.isoImage, self.pos[1], self.pos[2], self.direction)
			end
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	return self
end

return NewProjectile
