
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local EffectDefs = require("entities/effectDefs")
local NewEffect = require("entities/effect")

local self = {}
local api = {}

function api.Spawn(name, pos, scale, velocity)
	local def = EffectDefs.defs[name]
	local data = {
		pos = pos,
		scale = scale, -- optional
		velocity = velocity, -- optional
	}
	if def.interface then
		IterableMap.Add(self.interfaceEffects, NewEffect(data, def))
	else
		IterableMap.Add(self.worldEffects, NewEffect(data, def))
	end
end

function api.SpawnDust(pos, velocity, speed, dt, spawnMult)
	if math.random()*dt < speed*0.001*(spawnMult or 1) then
		api.Spawn("dust", util.Add(util.Add(util.SetLength(-8, velocity), util.RandomPointInCircle(4)), pos), math.random()*0.3 + 0.7, util.RandomPointInCircle(2))
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

function api.GetActivity()
	return IterableMap.Count(self.worldEffects)
end

function api.GetActivityInterface()
	return IterableMap.Count(self.interfaceEffects)
end

function api.Initialize()
	self = {
		worldEffects = IterableMap.New(),
		interfaceEffects = IterableMap.New(),
		animationTimer = 0
	}
end

return api
