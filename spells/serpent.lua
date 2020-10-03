
local util = require("include/util")
local Resources = require("resourceHandler")

local function sineMultiplier(i)
    local multiplier = 1
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return multiplier
end

local function NewSpell(player, modifiers)

    local nProjectiles = 2

	local self = {}
    
    self.modifiers = modifiers or {}
    self.projectiles = {}
    self.amplitude = 80
    self.phaseLength = 2
    
    self.pos, self.velocity = player.GetPhysics()
    self.currentPhase = 0
    
    local launchVelocity = util.SetLength(5, self.velocity)
    
	self.velocity = util.Add(self.velocity, launchVelocity);
    
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
    end
	
	function self.Update(dt)
		self.pos = util.Add(util.Mult(dt*60, self.velocity), self.pos)
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k in pairs(self.projectiles) do
            local perpvector = {}
            perpvector[1], perpvector[2] = util.RotateVector(self.velocity[1],self.velocity[2],math.pi/2)
            perpvector = util.SetLength(1, perpvector)
            self.projectiles[k].pos = util.Add(util.Mult(math.sin(phaseAngle)*self.amplitude*sineMultiplier(k),perpvector), self.pos)
        end
	end
	
	function self.Draw()
		for k in pairs(self.projectiles) do
            Resources.DrawIsoImage("fireball", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity))
        end
	end
	
	return self
end

return NewSpell
