
local util = require("include/util")
local Resources = require("resourceHandler")

local function speedMultiplier(i)
    local multiplier = math.floor(i/2) * 0.2
    if math.fmod(i,2) == 0 then
        multiplier = -multiplier
    end
    return 1+multiplier
end

local function NewSpell(player, modifiers)

    local nProjectiles = 4

	local self = {}
	
	self.pos, self.velocity = player.GetPhysics()
    self.modifiers = modifiers or {}
    self.projectiles = {}
    
    for i = 1,nProjectiles do
        self.projectiles[i] = {}
        self.projectiles[i].pos, self.projectiles[i].velocity = self.pos, self.velocity
        local launchVelocity = util.SetLength(15*speedMultiplier(i), self.projectiles[i].velocity)
        self.projectiles[i].velocity = util.Add(self.projectiles[i].velocity, launchVelocity);
        self.projectiles[i].alive = true
    end
	
	function self.Update(Terrain, dt)
        -- check for spell termination
        local anyAlive = false
        for k in pairs(self.projectiles) do 
            if self.projectiles[k].alive then anyAlive = true end
        end
        if not anyAlive then return true end
        
        for k in pairs(self.projectiles) do
            -- move
            self.projectiles[k].pos = util.Add(util.Mult(dt*60, self.projectiles[k].velocity), self.projectiles[k].pos)
            
            -- check collision
            local collide = Terrain.GetTerrainCollision(self.projectiles[k].pos, 5, false, true, nil, dt)
            if collide then
                self.projectiles[k].alive = false
            end
        end
	end
	
	function self.Draw()
		for k in pairs(self.projectiles) do
            if self.projectiles[k].alive then
                Resources.DrawIsoImage("fireball", self.projectiles[k].pos[1], self.projectiles[k].pos[2], util.Angle(self.projectiles[k].velocity))
            end
        end
	end
	
	return self
end

return NewSpell
