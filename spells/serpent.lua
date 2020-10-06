
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")
local EffectHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")

local function sineMultiplier(i)
    local multiplier = math.floor((i+1)/2)
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return multiplier
end

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    SoundHandler.PlaySound("serpent_shoot")
    
    -- uniform properties
    local baseN = 2

    -- properties derived from modifiers
    local nProjectiles = 2 + math.min(math.floor(level/2)*2, 6)
    local myDamage = 40 + 10*level
    local myAmplitude = 130 * (math.pow(0.75,nProjectiles/2))*(1 + level*0.25)
    local myPhaseLength = 2.4 * math.max(1 - 0.04 * level, 0.5)
    local baseSpeed = 4.5 + level

    -- setting up the spell
	local self = {}
    self.pos, self.velocity = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = 10
    self.amplitude = myAmplitude
    self.phaseLength = myPhaseLength
    self.currentPhase = 0
	self.velocity = util.Add(self.velocity, util.SetLength(baseSpeed, self.velocity));

    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage}
    end
	
	function self.Update(Terrain, Enemies, dt)
        -- check for spell termination
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then return true end
        
        local anyAlive = false
        for k = 1, #self.projectiles do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then return true end

        -- physics update
		self.pos = util.Add(util.Mult(dt*60, self.velocity), self.pos)
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k = 1, #self.projectiles do
			if self.projectiles[k].hitMult then
					self.projectiles[k].hitMult = self.projectiles[k].hitMult - 1.4*dt
				if self.projectiles[k].hitMult < 1 then
					self.projectiles[k].hitMult = false
				end
			end
			
            -- move
            local perpvector = {}
            perpvector = util.RotateVector(self.velocity, math.pi/2)
            perpvector = util.SetLength(1, perpvector)
            self.projectiles[k].pos = util.Add(util.Mult(math.sin(phaseAngle)*self.amplitude*sineMultiplier(k),perpvector), self.pos)
            
            -- check collision
            local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 30, false, self.projectiles[k].effect.id, nil, dt)
            if collided then
                collided.ProjectileImpact(self.projectiles[k].effect)
                -- self.projectiles[k].alive = false
                -- Consider whether serpent should pierce obstacles.
            else
                collided = Enemies.DetectCollision(self.projectiles[k].pos, 30, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
					EffectHandler.Spawn("serpent_hit", self.projectiles[k].pos)
					self.projectiles[k].hitMult = 1.8
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    -- Do not destroy projectile, serpent pierces enemies
                end
            end
        end
	end
	
	function self.Draw(drawQueue)
		for k = 1, #self.projectiles do
			if self.projectiles[k].alive then
				drawQueue:push({
					y=self.projectiles[k].pos[2],
					f=function() 
                        Resources.DrawIsoImage("serpent", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity), false, (self.projectiles[k].hitMult or 1)) 
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
