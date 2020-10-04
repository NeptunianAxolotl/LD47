
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

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
    self.playerRef = player
    self.maxlifetime = 10
    
    self.pos, self.facing = player.GetPhysics()
    self.currentPhase = 0
    self.lifetime = 0

    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = 50}
        self.projectiles[i].lives = 5
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
        local previousCentrePos = self.pos
		self.pos = self.playerRef.GetPhysics()
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k in pairs(self.projectiles) do
            if self.projectiles[k].alive then
                -- move
                local currentRelPos = util.Subtract(self.projectiles[k].pos, previousCentrePos)
                local wantedRelPos = {}
                local startvec = util.SetLength(self.radius, self.facing)
                local wantedRelPos  = util.RotateVector(startvec, phaseAngle + phaseModifier(k))
                local wantedChange = util.Subtract(wantedRelPos, currentRelPos)
                local maxDistance = self.maxVelocity * dt * 60
                if util.Dist(wantedChange[1], wantedChange[2], 0, 0) <= maxDistance then
                    currentRelPos = wantedRelPos
                else
                    currentRelPos = util.Add(util.SetLength(maxDistance,wantedChange),currentRelPos)
                end
                self.projectiles[k].pos = util.Add(currentRelPos,self.pos)
                
                -- check collision
                local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, 5, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    -- self.projectiles[k].alive = false 
                    -- Consider whether wisp should be destroyed by obstacles.
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
	end
	
	function self.Draw(drawQueue)
		for k in pairs(self.projectiles) do
			if self.projectiles[k].alive then
				drawQueue:push({
					y=self.projectiles[k].pos[2],
					f=function() Resources.DrawImage("rock_1", self.projectiles[k].pos[1], self.projectiles[k].pos[2]) end,
				})
			end
		end
	end
	
	return self
end

return NewSpell
