local util = require("include/util")
local Resources = require("resourceHandler")
local spellutil = require("spells/spellutil")

local function NewSpell(player, modifiers)

    modifiers = modifiers or {}
    
    -- properties derived from modifiers
    local myMult = 2
    local myDuration = 0.8
    
    -- setting up the spell
    local self = {}
    self.lifetime = myDuration
    self.speedmult = myMult
    
    player.SetSpeedMult(player.GetSpeedMult() * self.speedmult)
    
    function self.Update(Terrain, Enemies, dt)
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then
            player.SetSpeedMult(player.GetSpeedMult() / self.speedmult)
            return true
        end
    end
    
    function self.Draw(drawQueue)
        -- some particle effect nonsense I guess
    end
    
    return self
end

return NewSpell