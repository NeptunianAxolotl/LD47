
local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")
local EffectHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")
local SPELL_NAME = "wisp"

local lookup = {0, math.pi, math.pi / 2, 3 / 2 * math.pi}

local function phaseModifier(i)
    local modifier = lookup[math.fmod(i-1,4)+1]
    if math.fmod(i-1,8) > 3 then
        modifier = modifier + math.pi / 4
    end
    return modifier
end

local wispSize = 40

local function NewSpell(player, modifies, level)

    modifiers = modifiers or {}
    SoundHandler.PlaySound("wisp_shoot")
    
    -- uniform properties
    local baseN = 2
    
    -- properties derived from modifiers
    local nProjectiles = 2 
    local myDamage = 60
    local myRadius = 130 + 25*level
    local myPhaseLength = 2 * math.max((1 - 0.08 * (level-1)),0.4)
    local myDuration = 9 + level
    local myLives = 2 + math.floor((level-1)/2)

    -- setting up the spell
	local self = {}
    self.pos, self.facing = player.GetPhysics()
    self.modifiers = modifiers
    self.projectiles = {}
    self.lifetime = myDuration
    self.phaseLength = myPhaseLength 
    self.sizeMult = 1 + math.min((0.1 * (level-1)),1)
    self.radius = myRadius + wispSize * self.sizeMult
    self.maxVelocity = 2 * math.pi * self.radius / (self.phaseLength * 60) + 1
    self.playerRef = player
    self.currentPhase = 0
    
    -- setting up the projectiles
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos = self.pos
        self.projectiles[i].velocity = self.velocity
        self.projectiles[i].alive = true
        self.projectiles[i].effect = {id = spellutil.newProjID(), damage = myDamage}
        self.projectiles[i].lives = myLives
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
        local previousCentrePos = self.pos
		self.pos = self.playerRef.GetPhysics()
        self.currentPhase = math.fmod(self.currentPhase + dt, self.phaseLength)
        local phaseAngle = self.currentPhase / self.phaseLength * 2 * math.pi
        for k = 1, #self.projectiles do
            if self.projectiles[k].alive then
                if self.projectiles[k].hitMult then
					self.projectiles[k].hitMult = self.projectiles[k].hitMult - 1.4*dt
					if self.projectiles[k].hitMult < 1 then
						self.projectiles[k].hitMult = false
					end
				end
				
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
                local collided = Terrain.GetTerrainCollision(self.projectiles[k].pos, wispSize * self.sizeMult, false, self.projectiles[k].effect.id, nil, dt)
                if collided then
                    collided.ProjectileImpact(self.projectiles[k].effect)
                    -- self.projectiles[k].alive = false 
                    -- Consider whether wisp should be destroyed by obstacles.
                else
                    collided = Enemies.DetectCollision(self.projectiles[k].pos, wispSize * self.sizeMult, false, self.projectiles[k].effect.id, nil, dt)
                    if collided then
						EffectHandler.Spawn("wisp_hit", self.projectiles[k].pos)
						self.projectiles[k].hitMult = 1.8
                        collided.ProjectileImpact(self.projectiles[k].effect, SPELL_NAME)
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
		for k = 1, #self.projectiles do
			if self.projectiles[k].alive then
				drawQueue:push({
					y=self.projectiles[k].pos[2],
					f=function() 
                        Resources.DrawAnimation("wisp", self.projectiles[k].pos[1], self.projectiles[k].pos[2], self.lifetime, nil, nil, self.sizeMult*(self.projectiles[k].hitMult or 1))  
                        -- love.graphics.setColor(0,0,1)
                        -- love.graphics.setLineWidth(2)
                        -- love.graphics.circle("line", self.projectiles[k].pos[1], self.projectiles[k].pos[2], wispSize * self.sizeMult) 
                    end,
				})
			end
		end
	end
	
	return self
end

return NewSpell
