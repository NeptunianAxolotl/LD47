
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")
local SoundHandler = require("soundHandler")

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    SoundHandler.PlaySound("shotgun_shoot")
    
    -- uniform properties
    local baseN = 5

    -- properties derived from modifiers
    local nProjectiles = 5 + (level-1)*2
    local sprayAngle = 0.2 * ((nProjectiles*3)/(nProjectiles+baseN*2) )
    local myDamage = 55
    local baseSpeed = 15 + level
    local myLives = 1

    -- setting up the spell
	local self = {}
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = 10
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = player.GetPhysics()
        local launchVelocity = util.SetLength(baseSpeed - 0.4 + 0.8 * math.random(), self.projectiles[i].velocity)
        launchVelocity = util.RotateVector(launchVelocity, math.random() * sprayAngle * 2 - sprayAngle)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage}
        self.projectiles[i].lives = myLives
    end
	
	function self.Update(Terrain, Enemies, dt)
        -- check for spell termination
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then return true end
        
        local anyAlive = false
        for k in pairs(self.projectiles) do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then return true end
    
        for k in pairs(self.projectiles) do
            -- move
            self.projectiles[k].pos = util.Add(util.Mult(dt*60, self.projectiles[k].velocity), self.projectiles[k].pos)
            
            -- check collision
            local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 15, false, self.projectiles[k].effect.id, nil, dt)
            if collided then
                collided.ProjectileImpact(self.projectiles[k].effect)
                self.projectiles[k].alive = false
            else
                collided = Enemies.DetectCollision(self.projectiles[k].pos, 15, false, self.projectiles[k].effect.id, nil, dt)
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
					f=function() 
                        Resources.DrawIsoImage("shotgun", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity)) 
                        -- love.graphics.setColor(0,0,1)
                        -- love.graphics.setLineWidth(2)
                        -- love.graphics.circle("line", self.projectiles[k].pos[1], self.projectiles[k].pos[2], 15) 
                    end,
				})
			end
        end
	end
	
	return self
end

return NewSpell
