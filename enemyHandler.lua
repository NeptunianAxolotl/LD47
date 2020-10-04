
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Terrain = require("terrainHandler")
local CreatureDefs = require("entities/creatureDefs")
local NewCreature = require("entities/creature")

local SPAWN_OFFSET = {0, 400}
local OUTER_SPAWN = 1500
local INNER_SPAWN = 1200
local START_ANGLE, END_ANGLE = math.pi*0.2, math.pi*0.8

local self = {
	activeEnemies = IterableMap.New(),
	spawnCheckAcc = 0,
}

local function SpawnNewEnemies(player)
	local playerPos, playerVel, playerSpeed = player.GetPhysics()
	
	local spawnCentre = util.Add(playerPos, SPAWN_OFFSET)
	local enemyCount = math.random(0, 7)
	
	local spawnDistribution = util.GenerateDistributionFromBoundedRandomWeights(CreatureDefs.spawnWeights)
	
	for i = 1, enemyCount do
		local creatureDef = CreatureDefs.defs[util.SampleDistribution(spawnDistribution)]
		local creaturePos = util.Add(spawnCentre, util.RandomPointInAnnulus(INNER_SPAWN, OUTER_SPAWN, START_ANGLE, END_ANGLE))
		
		IterableMap.Add(self.activeEnemies, NewCreature({pos = creaturePos}, creatureDef))
	end
end

function self.DetectCollision(otherPos, otherRadius, otherCreatureIndex, projectile, player, dt)
	local maxIndex, keyByIndex, dataByKey = IterableMap.GetBarbarianData(self.activeEnemies)
	for i = 1, maxIndex do
		local v = dataByKey[keyByIndex[i]]

        if projectile then 
            -- check to see if this projectile is on the ignore list
            for a, b in pairs(v.projIgnoreFresh) do
                if b == projectile then 
                    return false 
                end
            end
            for a, b in pairs(v.projIgnoreStale) do
                if b == projectile then 
                    return false 
                end
            end
        end

		if v.IsColliding(otherPos, otherRadius, otherCreatureIndex, projectile, player, dt) then
			return v
		end
	end
	return false
end

function self.Update(player, dt)
	self.spawnCheckAcc = self.spawnCheckAcc - dt
	if self.spawnCheckAcc <= 0 then
		SpawnNewEnemies(player)
		self.spawnCheckAcc = 0.5 + math.random()*3
	end

	IterableMap.ApplySelf(self.activeEnemies, "Update", Terrain, self, player, dt)
end

function self.Draw()
	IterableMap.ApplySelf(self.activeEnemies, "Draw")
end

return self
