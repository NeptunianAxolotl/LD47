
local IterableMap = require("include/IterableMap")
local Terrain = require("terrainHandler")

local self = {
	activeSpells = IterableMap.New(),
	spellTypes = {}
}

local spellList = {
	"fireball",
    "shotgun",
    "serpent",
    "wisp"
}

function self.CastSpell(name, player, world)
	IterableMap.Add(self.activeSpells, self.spellTypes[name](player, world))
end

function self.Update(dt)
	IterableMap.ApplySelf(self.activeSpells, "Update", Terrain, dt)
end

function self.Draw()
	IterableMap.ApplySelf(self.activeSpells, "Draw")
end

function self.Initialize()
	for i = 1, #spellList do
		self.spellTypes[spellList[i]] = require("spells/" .. spellList[i])
	end
end

return self
