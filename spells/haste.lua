local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function NewSpell(player, modifiers)

    modifiers = modifiers or {}
    
    -- properties derived from modifiers
    local myMult = 2
    local myDuration = 0.6
    
    -- setting up the spell
    local self = {}
    self.lifetime = myDuration
    self.speedmult = myMult
    
    player.SetSpeedMult(self.speedmult)
    
    function self.Update(Terrain, Enemies, dt)
        self.lifetime = self.lifetime - dt
        player.SetSpeedMult(self.speedmult)
        if self.lifetime <= 0 then
            return true
        end
    end
    
    function self.Draw(drawQueue)
        -- some particle effect nonsense I guess
    end
    
    return self
end

return NewSpell