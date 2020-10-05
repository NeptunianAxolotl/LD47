local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    
    -- properties derived from modifiers
    local nProjectiles = 6
    local sprayAngle = 0.1
    local myMult = 4 * (level and 1+(0.25*(level-1)) or 1)
    local myDuration = 0.6 * (level and 1+(0.5*(level-1)) or 1)
    
    -- setting up the spell
    local self = {}
    self.pos, self.velocity = player.GetPhysics()
    self.lifetime = myDuration
    self.particleLifetime = 0.6
    self.speedmult = myMult
    self.projectiles = {}
    
    -- setting up particle effects
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = self.pos, self.velocity
        self.projectiles[i].velocity = util.Mult(-0.4-0.4*math.random(),self.projectiles[i].velocity)
        local angle = -sprayAngle*nProjectiles/2 + sprayAngle*(i-1)
        if angle > math.pi*2/3 then angle = math.fmod(angle, math.pi*2/3) end
        if angle < -math.pi*2/3 then angle = -math.fmod(-angle, math.pi*2/3) end
        self.projectiles[i].velocity = util.Add(util.RotateVector(self.projectiles[i].velocity, angle),self.velocity)
    end
    
    player.SetSpeedMult(self.speedmult)
    
    function self.Update(Terrain, Enemies, dt)
        self.lifetime = self.lifetime - dt
        self.particleLifetime = self.particleLifetime - dt
        player.SetSpeedMult(self.speedmult)
        if self.lifetime <= 0 then
            return true
        end
        
        for k in pairs(self.projectiles) do
            -- move
            self.projectiles[k].pos = util.Add(util.Mult(dt*60, self.projectiles[k].velocity), self.projectiles[k].pos)
        end
    end
    
    function self.Draw(drawQueue)
        if self.particleLifetime > 0 then
            for k in pairs(self.projectiles) do
                Resources.DrawImage("haste", self.projectiles[k].pos[1], self.projectiles[k].pos[2]) 
            end
        end
    end
    
    return self
end

return NewSpell