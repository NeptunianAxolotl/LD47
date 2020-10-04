
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function NewSpell(player, modifiers)

    modifiers = modifiers or {}
    
    -- uniform properties
    local baseN = 5

    -- properties derived from modifiers
    local nProjectiles = 5 + (modifiers.shotgun and modifers.shotgun * 3 or 0) + (modifiers.fireball and modifers.fireball or 0)
    local sprayAngle = 0.1 + (modifiers.fireball and modifiers.fireball * 0.05 or 0)
    local myDamage = 60 * (nProjectiles+baseN)/(nProjectiles*2)
    local baseSpeed = 15 * (modifiers.wisp and 0.5 + 0.5 / modifers.wisp or 1)
    local myLives = 1 + (modifiers.serpent and modifiers.serpent or 0)

    -- setting up the spell
	local self = {}
    self.modifiers = modifiers
    self.projectiles = {}
    self.maxlifetime = 10
    self.lifetime = 0
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = player.GetPhysics()
        local launchVelocity = util.SetLength(baseSpeed, self.projectiles[i].velocity)
        launchVelocity = util.RotateVector(launchVelocity, math.random() * sprayAngle * 2 - sprayAngle)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = 60}
        self.projectiles[i].lives = myLives
    end
	
	function self.Update(Terrain, Enemies, dt)
        -- check for spell termination
        self.lifetime = self.lifetime + dt
        if self.lifetime > self.maxlifetime then return true end
        
        local anyAlive = false
        for k in pairs(self.projectiles) do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then return true end
    
        for k in pairs(self.projectiles) do
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
	end
	
	return self
end

return NewSpell
