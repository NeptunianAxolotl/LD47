local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function speedMultiplier(i)
    local multiplier = math.floor(i/2) * 0.2
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return 1+multiplier
end

local function NewSpell(player, modifiers)

    modifiers = modifiers or {}

    -- uniform properties
    local exploDuration = 0.3 -- graphics only

    -- properties derived from modifiers
    local nProjectiles = 1
    local myDamage = 100
    local myFire = 100
    local exploDamage = 80
    local exploRadius = 150
    local baseSpeed = 15
    
    -- setting up the spell
	local self = {}
	self.pos, self.velocity = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.maxlifetime = 10
    self.lifetime = 0
    self.explosionEffects = {}
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = self.pos, self.velocity
        local launchVelocity = util.SetLength(baseSpeed*speedMultiplier(i), self.projectiles[i].velocity)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage, fire = myFire}
        self.projectiles[i].exploEffect = {damage = exploDamage}
    end
	
	function self.Update(Terrain, Enemies, dt)
        -- check for spell termination
        self.lifetime = self.lifetime + dt
        if self.lifetime > self.maxlifetime then return true end
        
        local anyAlive = false
        for k in pairs(self.projectiles) do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then 
            if not (#self.explosionEffects > 0 and self.explosionEffects[#self.explosionEffects].timer > 0) then
                return true -- kill
            end
        end
        
        for f in pairs(self.explosionEffects) do
            if self.explosionEffects[f].timer > 0 then
                self.explosionEffects[f].timer = self.explosionEffects[f].timer - dt
            end
        end
        
        for k in pairs(self.projectiles) do
            if self.projectiles[k].alive then
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
                        self.projectiles[k].alive = false
                    end
                end
                
                if collided then
                    -- explosion
                    local enemysplash = Enemies.DetectInCircle(self.projectiles[k].pos, exploRadius)
                    for t in pairs(enemysplash) do
                        enemysplash[t].ProjectileImpact(self.projectiles[k].exploEffect)
                    end
                    self.explosionEffects[#self.explosionEffects+1] = {timer = exploDuration, x = self.projectiles[k].pos[1], y = self.projectiles[k].pos[2]}
                end
            end
        end
        
        
	end
	
	function self.Draw(drawQueue)
		for k in pairs(self.projectiles) do
			if self.projectiles[k].alive then
				drawQueue:push({
					y=self.projectiles[k].pos[2],
					f=function() Resources.DrawIsoImage("fireball", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity)) end,
				})
			end
		end
        for f in pairs(self.explosionEffects) do
            if self.explosionEffects[f].timer > 0 then
                drawQueue:push({
					y=self.explosionEffects[f].y,
                    f=function() 
                        love.graphics.setColor(1,0.2,0)
                        love.graphics.circle("line", self.explosionEffects[f].x, self.explosionEffects[f].y, (exploDuration-self.explosionEffects[f].timer)/exploDuration*exploRadius) 
                    end,
				})
            end
        end
	end
	
	return self
end

return NewSpell
