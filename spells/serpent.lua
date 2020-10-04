
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function sineMultiplier(i)
    local multiplier = math.floor((i+1)/2)
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return multiplier
end

local function NewSpell(player, modifiers)

    modifiers = modifiers or {}

    local nProjectiles = 2 + (modifiers.shotgun and modifers.shotgun * 2 or 0)

	local self = {}
    
    self.modifiers = modifiers
    self.projectiles = {}
    self.amplitude = 80
    self.phaseLength = 2
    self.maxlifetime = 10
    self.lifetime = 0
    
    self.pos, self.velocity = player.GetPhysics()
    self.currentPhase = 0
    
    local launchVelocity = util.SetLength(5, self.velocity)
    
	self.velocity = util.Add(self.velocity, launchVelocity);
    
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = 100}
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

        -- physics update
		self.pos = util.Add(util.Mult(dt*60, self.velocity), self.pos)
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k in pairs(self.projectiles) do
            -- move
            local perpvector = {}
            perpvector = util.RotateVector(self.velocity, math.pi/2)
            perpvector = util.SetLength(1, perpvector)
            self.projectiles[k].pos = util.Add(util.Mult(math.sin(phaseAngle)*self.amplitude*sineMultiplier(k),perpvector), self.pos)
            
            -- check collision
            local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 5, false, self.projectiles[k].effect.id, nil, dt)
            if collided then
                collided.ProjectileImpact(self.projectiles[k].effect)
                -- self.projectiles[k].alive = false
                -- Consider whether serpent should pierce obstacles.
            else
                collided = Enemies.DetectCollision(self.projectiles[k].pos, 5, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    -- Do not destroy projectile, serpent pierces enemies
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
