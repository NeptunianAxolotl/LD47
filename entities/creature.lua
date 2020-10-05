
local util = require("include/util")
local Resources = require("resourceHandler")

local DRAW_DEBUG = false

local PROJ_TIMEOUT = 0.6

local function NewCreature(self, def)
	-- pos
	self.health = def.health + math.random()*def.healthRange
	self.direction = 0
	self.velocity = {0, 0}
    self.projIgnoreTime = 0
    self.projIgnoreFresh = {}
    self.projIgnoreStale = {}
	
	if def.goalRandomOffsetX then
		self.randomGoalOffset = util.RandomPointInEllipse(def.goalRandomOffsetX, def.goalRandomOffsetY)
	end
	
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
		local playerPos = player.GetPhysics()
		if playerPos[2] > self.pos[2] + def.despawnDistance then
			return true -- Remove
		end
		
        if self.health <= 0 then
            return true -- Remove
        end
		self.oldPos = self.pos
        
		if def.updateFunc then
			def.updateFunc(self, def, Terrain, Enemies, player, dt)
		end
		
		self.pos = util.Add(self.pos, util.Mult(dt, self.velocity))
		self.velocity = util.Mult(1 - dt, self.velocity)
        
        self.projIgnoreTime = self.projIgnoreTime + dt
        if self.projIgnoreTime > (PROJ_TIMEOUT / 2) then
            self.projIgnoreTime = self.projIgnoreTime - PROJ_TIMEOUT
            self.projIgnoreStale = self.projIgnoreFresh
            self.projIgnoreFresh = {}
        end
	end
    
    function self.ProjectileImpact(projEffect)
        if projEffect then
            if projEffect.id then
                self.projIgnoreFresh[#self.projIgnoreFresh+1] = projEffect.id
            end
            if projEffect.damage then
                self.health = self.health - projEffect.damage
            end
        end
    end
	
	function self.AddPosition(posToAdd)
		self.velocity = util.Add(self.velocity, util.Mult(def.speedChangeFactor or 0.4, posToAdd))
		self.pos = util.Add(self.pos, util.Mult(def.posChangeFactor or 0.4, posToAdd))
	end
	
	function self.AddSlowTime(toAdd)
		self.slowTime = math.min(1, (self.slowTime or 0.1) + toAdd)*(def.slowTimeMult or 1)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=self.pos[2]; f=function()
			Resources.DrawIsoImage(def.imageName, self.pos[1], self.pos[2], self.drawDir or self.direction)
			if def.turretImage then
				Resources.DrawIsoImage(def.turretImage, self.pos[1], self.pos[2], self.turretDirection)
			end
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	return self
end

return NewCreature
