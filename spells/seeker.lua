local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function NewSpell(player, modifies, level)
    
    modifiers = modifiers or {}
    
    -- uniform properties
    local baseN = 1
    local maxLifetime = 10
    local exploDuration = 0.2 -- graphics only
    local mySearchRad = 500
    
    
    -- properties derived from modifiers
    local nProjectiles = 1 + (modifiers.shotgun and modifiers.shotgun * 2 or 0)
    local sprayAngle = (nProjectiles - 1) * 0.04
    local myDamage = 50 * (nProjectiles+baseN)/(nProjectiles*2) * (level and 1+(0.5*level) or 1)
    local exploDamage = (modifiers.fireball and 25 + modifiers.fireball * 25 or 0) * (nProjectiles+baseN)/(nProjectiles*2)
    local exploRadius = 80 * (modifiers.fireball and 1+(modifiers.fireball*0.25) or 1)
    local baseSpeed = 5 * (modifiers.wisp and 0.5 + 0.5 / modifers.wisp or 1)
    local myLives = 1 + (modifiers.serpent and modifiers.serpent or 0)
    local turnspeed = math.pi/50 * (level and 1+0.3*(3*level)/(level+2) or 1)
    
    -- setting up the spell
	local self = {}
	self.pos, self.velocity = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = maxLifetime
    self.explosionEffects = {}
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = self.pos, self.velocity
        local launchVelocity = util.SetLength(baseSpeed, self.projectiles[i].velocity)
        launchVelocity = util.RotateVector(launchVelocity, math.random() * sprayAngle * 2 - sprayAngle)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage}
        if exploDamage > 0 then self.projectiles[i].exploEffect = {damage = exploDamage} end
        self.projectiles[i].lives = myLives
        self.projectiles[i].searchRadius = mySearchRad
        self.projectiles[i].turnSpeed = turnspeed
    end
    
    function self.Update(Terrain, Enemies, dt)
        -- check for spell termination
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then return true end
        
        local anyAlive = false
        for k in pairs(self.projectiles) do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then 
            if not (#self.explosionEffects > 0 and self.explosionEffects[#self.explosionEffects].timer > 0) then
                return true -- kill
            end
        end
        
        if self.explosionEffects then
            for f in pairs(self.explosionEffects) do
                if self.explosionEffects[f].timer > 0 then
                    self.explosionEffects[f].timer = self.explosionEffects[f].timer - dt
                end
            end
        end
        
        for k in pairs(self.projectiles) do
            if self.projectiles[k].alive then
            
                -- seek enemy
                local nearbys = Enemies.DetectInCircle(self.projectiles[k].pos, self.projectiles[k].searchRadius)
                if #nearbys > 0 then
                    -- choose enemy
                    local bestVector = nil
                    local bestDist = 100000
                    for t in pairs(nearbys) do
                        local target = nearbys[t].GetPhysics()
                        local vectorToTarget = util.Subtract(target, self.projectiles[k].pos)
                        local distance = util.AbsVal(vectorToTarget)
                        local angle = util.GetAngleBetweenUnitVectors(util.Unit(vectorToTarget),util.Unit(self.projectiles[k].velocity))
                        if angle < math.pi/6 or (distance > mySearchRad/2 and angle < math.pi/3) then
                            distance = distance / 100
                        end
                        if distance < bestDist then bestVector = vectorToTarget end
                    end
                    -- divert towards enemy
                    if bestVector then
                        local currentAngle = util.Angle(self.projectiles[k].velocity)
                        local targetAngle = util.Angle(bestVector)
                        local angleDiff = util.AngleSubtractShortest(targetAngle,currentAngle)
                        if math.abs(angleDiff) > self.projectiles[k].turnSpeed then 
                            if angleDiff > 0 then 
                                angleDiff = self.projectiles[k].turnSpeed
                            else
                                angleDiff = -self.projectiles[k].turnSpeed
                            end
                        end
                        self.projectiles[k].velocity = util.RotateVector(self.projectiles[k].velocity,angleDiff)
                    end
                end
            
                -- move
                self.projectiles[k].pos = util.Add(util.Mult(dt*60, self.projectiles[k].velocity), self.projectiles[k].pos)
                
                -- check collision
                local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 5, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    self.projectiles[k].alive = false
                else
                    collided = Enemies.DetectCollision(self.projectiles[k].pos, 5, false, self.projectiles[k].effect.id, nil, dt)
                    if collided then
                        collided.ProjectileImpact(self.projectiles[k].effect)
                        self.projectiles[k].lives = self.projectiles[k].lives - 1
                        if self.projectiles[k].lives <= 0 then
                            self.projectiles[k].alive = false
                        end
                    end
                end
                
                if collided then
                    -- explosion
                    if exploDamage > 0 then
                        local enemysplash = Enemies.DetectInCircle(self.projectiles[k].pos, exploRadius)
                        for t in pairs(enemysplash) do
                            enemysplash[t].ProjectileImpact(self.projectiles[k].exploEffect)
                        end
                        self.explosionEffects[#self.explosionEffects+1] = {timer = exploDuration, x = self.projectiles[k].pos[1], y = self.projectiles[k].pos[2]}
                    end
                end
            end
        end
	end
	
	function self.Draw(drawQueue)
		for k in pairs(self.projectiles) do
			if self.projectiles[k].alive then
				drawQueue:push({
					y=self.projectiles[k].pos[2],
					f=function() Resources.DrawIsoAnimation("seeker", self.projectiles[k].pos[1], self.projectiles[k].pos[2], self.lifetime, util.Angle(self.projectiles[k].velocity)) end,
				})
			end
		end
        if self.explosionEffects then
            for f in pairs(self.explosionEffects) do
                if self.explosionEffects[f].timer > 0 then
                    drawQueue:push({
                        y=self.explosionEffects[f].y,
                        f=function() 
                            love.graphics.setColor(1,0,1)
                            love.graphics.setLineWidth(4)
                            love.graphics.circle("line", self.explosionEffects[f].x, self.explosionEffects[f].y, (exploDuration-self.explosionEffects[f].timer)/exploDuration*exploRadius) 
                        end,
                    })
                end
            end
        end
	end
    
    return self
    
end

return NewSpell