
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local EffectDefs = require("entities/effectDefs")
local NewEffect = require("entities/effect")

local self = {}
local api = {}

function api.Spawn(name, pos)
	local def = EffectDefs.defs[name]
	if def.interface then
		IterableMap.Add(self.interfaceEffects, NewEffect({pos = pos}, def))
	else
		IterableMap.Add(self.worldEffects, NewEffect({pos = pos}, def))
	end
end

function api.Update(dt)
	IterableMap.ApplySelf(self.worldEffects, "Update", dt)
	IterableMap.ApplySelf(self.interfaceEffects, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.worldEffects, "Draw", drawQueue)
end

function api.DrawInterface()
	IterableMap.ApplySelf(self.interfaceEffects, "DrawInterface")
end

function api.Initialize()
	self = {
		worldEffects = IterableMap.New(),
		interfaceEffects = IterableMap.New(),
		animationTimer = 0
	}
end

return api
