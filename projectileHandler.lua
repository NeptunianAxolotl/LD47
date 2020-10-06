
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Terrain = require("terrainHandler")
local ProjectileDefs = require("entities/projectileDefs")
local NewProjectile = require("entities/projectile")

local self = {}
local api = {}

function api.SpawnProjectile(projName, pos, velocity)
	local projectileDef = ProjectileDefs.defs[projName]
	if projectileDef.spawnOffset then
		pos = util.Add(pos, projectileDef.spawnOffset) 
	end
	
	IterableMap.Add(self.activeProjectiles, NewProjectile({pos = pos, velocity = velocity}, projectileDef))
end

function api.DetectCollision(otherPos, otherRadius)
	local maxIndex, keyByIndex, dataByKey = IterableMap.GetBarbarianData(self.activeProjectiles)
	for i = 1, maxIndex do
		local v = dataByKey[keyByIndex[i]]
		if v.IsColliding(otherPos, otherRadius, otherCreatureIndex, projectile, player, dt) then
			return v
		end
	end
	return false
end

function api.DetectInCircle(otherPos, otherRadius)
    local maxIndex, keyByIndex, dataByKey = IterableMap.GetBarbarianData(self.activeProjectiles)
    local outputTable = {}
    for i = 1, maxIndex do
		local v = dataByKey[keyByIndex[i]]
        if v.IsColliding(otherPos, otherRadius, nil, nil, nil, dt) then
			outputTable[#outputTable+1] = v
		end
    end
    return outputTable
end

function api.Update(player, dt)
	IterableMap.ApplySelf(self.activeProjectiles, "Update", Terrain, api, player, dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.activeProjectiles, "Draw", drawQueue)
end

function api.GetActivity()
	return IterableMap.Count(self.activeProjectiles)
end

function api.Initialize()
	self = {
		activeProjectiles = IterableMap.New(),
	}
end

return api
