
local util = require("include/util")
local Resources = require("resourceHandler")

local lookup = {0, math.pi, math.pi / 2, 3 / 2 * math.pi}

local function phaseModifier(i)
    local modifier = lookup[math.fmod(i-1,4)+1]
    if math.fmod(i-1,8) > 3 then
        modifier = modifier + math.pi / 4
    end
    return modifier
end

local function NewSpell(player, modifiers)

    local nProjectiles = 2

	local self = {}
    
    self.modifiers = modifiers or {}
    self.projectiles = {}
    self.radius = 80
    self.phaseLength = 2
    self.maxVelocity = 2 * math.pi * self.radius / (self.phaseLength * 60) + 1
    
    self.pos, self.facing = player.GetPhysics()
    self.currentPhase = 0

    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
    end
	
	function self.Update(dt)
        local previousCentrePos = self.pos
		--self.pos = new player pos
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k in pairs(self.projectiles) do
            local currentRelPos = util.Subtract(self.projectiles[k].pos, previousCentrePos)
            local wantedRelPos = {}
            local startvec = util.SetLength(self.radius, self.facing)
            wantedRelPos[1], wantedRelPos[2] = util.RotateVector(startvec[1],startvec[2], phaseAngle + phaseModifier(k))
            local wantedChange = util.Subtract(wantedRelPos, currentRelPos)
            local maxDistance = self.maxVelocity * dt * 60
            if util.Dist(wantedChange[1], wantedChange[2], 0, 0) <= maxDistance then
                currentRelPos = wantedRelPos
            else
                currentRelPos = util.Add(util.SetLength(maxDistance,wantedChange),currentRelPos)
            end
            self.projectiles[k].pos = util.Add(currentRelPos,self.pos)
        end
	end
	
	function self.Draw()
		for k in pairs(self.projectiles) do
            Resources.DrawImage("rock_1", self.projectiles[k].pos[1], self.projectiles[k].pos[2])
        end
	end
	
	return self
end

return NewSpell
