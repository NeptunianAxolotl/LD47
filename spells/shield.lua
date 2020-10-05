
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")
local Projectiles = require("projectileHandler")

local lookup = {0, math.pi, math.pi / 2, 3 / 2 * math.pi}

local function phaseModifier(i)
    local modifier = lookup[math.fmod(i-1,4)+1]
    if math.fmod(i-1,8) > 3 then
        modifier = modifier + math.pi / 4
    end
    return modifier
end

local shieldSize = 35

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    
    -- uniform properties
    local baseN = 2
    
    -- properties derived from modifiers
    local nProjectiles = 2 + (modifiers.shotgun and modifers.shotgun * 2 or 0)
    local myRadius = 80 + (modifiers.fireball and modifiers.fireball * 30 or 0)
    local myPhaseLength = 2 * (modifiers.serpent and 0.6 + 0.4 / modifers.serpent or 1)
    local myDuration = 10 * (modifiers.wisp and 1+modifiers.wisp*0.5 or 1)
    local myLives = 2 + math.floor((level and (level-1) or 0) * (nProjectiles+baseN)/(nProjectiles*2) + 0.5) -- basically rounding

    -- setting up the spell
	local self = {}
    self.pos, self.facing = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = myDuration
    self.radius = myRadius
    self.phaseLength = myPhaseLength
    self.maxVelocity = 2 * math.pi * self.radius / (self.phaseLength * 60) + 1
    self.playerRef = player
    self.currentPhase = 0
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = 50}
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
                local collided = Projectiles.DetectCollision(self.projectiles[k].pos, 5)
                if collided then
                    collided.Kill()
                    self.projectiles[k].lives = self.projectiles[k].lives - 1
                    if self.projectiles[k].lives <= 0 then
                        self.projectiles[k].alive = false
                    end
                end
                -- Collides with enemy projectiles, which doesn't exist yet.
            end
        end
	end
	
	function self.Draw(drawQueue)
		for k in pairs(self.projectiles) do
			if self.projectiles[k].alive then
                if self.projectiles[k].lives > 1 then
                    drawQueue:push({
                        y=self.projectiles[k].pos[2],
                        f=function() 
                            Resources.DrawAnimation("shield", self.projectiles[k].pos[1], self.projectiles[k].pos[2], self.lifetime) 
                            -- love.graphics.setColor(0,0,1)
                            -- love.graphics.setLineWidth(2)
                            -- love.graphics.circle("line", self.projectiles[k].pos[1], self.projectiles[k].pos[2], shieldSize) 
                        end,
                    })
                else
                    drawQueue:push({
                        y=self.projectiles[k].pos[2],
                        f=function() 
                            Resources.DrawAnimation("shield_damaged", self.projectiles[k].pos[1], self.projectiles[k].pos[2], self.lifetime) 
                            -- love.graphics.setColor(0,0,1)
                            -- love.graphics.setLineWidth(2)
                            -- love.graphics.circle("line", self.projectiles[k].pos[1], self.projectiles[k].pos[2], shieldSize) 
                        end,
                    })
                end
			end
		end
	end
	
	return self
end

return NewSpell
