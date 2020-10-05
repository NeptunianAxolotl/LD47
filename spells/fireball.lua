local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")
local EffectHandler = require("effectsHandler")

local function speedMultiplier(i)
    local multiplier = math.floor(i/2) * 0.2
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return 1+multiplier
end

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    level = level or 1

    -- uniform properties
    local exploDuration = 0.3 -- graphics only
    local baseN = 1

    -- properties derived from modifiers
    local nProjectiles = 1 + math.floor(level/5)
    local myDamage = 100
    local myFire = 100
    local exploDamage = 70
    local exploRadius = 300 * (level and (1 + 0.25*(level-1)) or 1)
    local baseSpeed = 15
    local myLives = 1
    
    -- setting up the spell
	local self = {}
	self.pos, self.velocity = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = 10
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = self.pos, self.velocity
        local launchVelocity = util.SetLength(baseSpeed*speedMultiplier(i), self.projectiles[i].velocity)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage, fire = myFire}
        self.projectiles[i].exploEffect = {damage = exploDamage}
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
        if not anyAlive then 
            return true -- kill
        end
        
        
        for k in pairs(self.projectiles) do
            if self.projectiles[k].alive then
                -- move
                self.projectiles[k].pos = util.Add(util.Mult(dt*60, self.projectiles[k].velocity), self.projectiles[k].pos)
                
                -- check collision
                local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 30, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    self.projectiles[k].alive = false
                else
                    collided = Enemies.DetectCollision(self.projectiles[k].pos, 30, false, self.projectiles[k].effect.id, nil, dt)
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
                    local enemysplash = Enemies.DetectInCircle(self.projectiles[k].pos, exploRadius)
                    for t in pairs(enemysplash) do
                        enemysplash[t].ProjectileImpact(self.projectiles[k].exploEffect)
                    end
					EffectHandler.Spawn("fireball_explode", self.projectiles[k].pos, exploRadius/200)
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
                        Resources.DrawIsoImage("fireball", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity)) 
                        -- love.graphics.setColor(0,0,1)
                        -- love.graphics.setLineWidth(2)
                        -- love.graphics.circle("line", self.projectiles[k].pos[1], self.projectiles[k].pos[2], 30) 
                    end,
				})
			end
		end
	end
	
	return self
end

return NewSpell
