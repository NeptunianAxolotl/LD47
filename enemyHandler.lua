
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Terrain = require("terrainHandler")
local ProjectileHandler = require("projectileHandler")
local CreatureDefs = require("entities/creatureDefs")
local NewCreature = require("entities/creature")
local Progression = require("progression")

local self = {}
local api = {}

local function SpawnNewEnemies(player)
	if player.IsDead() then
		return
	end
	local playerPos, playerVel, playerSpeed = player.GetPhysics()
	
	local enemyCount = Progression.GetEnemySpawnCount(playerPos[2], IterableMap.Count(self.activeEnemies))
	
	local spawnDistribution = util.WeightsToDistribution(util.TableKeysToList(Progression.GetEnemySpawnWeights(playerPos[2], IterableMap.Count(self.activeEnemies)), CreatureDefs.indexToKey))
	
	for i = 1, enemyCount do
		local creatureDef = CreatureDefs.defs[util.SampleDistribution(spawnDistribution)]
		local creaturePos = util.Add(playerPos, creatureDef.getSpawnOffset(player))
		
		if not (creatureDef.isBoss and Progression.BossExists()) then
			IterableMap.Add(self.activeEnemies, NewCreature({pos = creaturePos}, creatureDef))
		end
	end
end

function api.DetectCollision(otherPos, otherRadius, otherCreatureIndex, projectile, player, dt)
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

function api.DetectInCircle(otherPos, otherRadius)
    local maxIndex, keyByIndex, dataByKey = IterableMap.GetBarbarianData(self.activeEnemies)
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
	self.spawnCheckAcc = self.spawnCheckAcc - dt
	if self.spawnCheckAcc <= 0 then
		SpawnNewEnemies(player)
		local playerPos, playerVel, playerSpeed = player.GetPhysics()
		self.spawnCheckAcc = Progression.GetNextEnemySpawnTime(playerPos[2], IterableMap.Count(self.activeEnemies))
	end
	
	IterableMap.ApplySelf(self.activeEnemies, "Update", Terrain, api, ProjectileHandler, player, dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.activeEnemies, "Draw", drawQueue)
end

function api.Initialize()
	self = {
		activeEnemies = IterableMap.New(),
		spawnCheckAcc = 0,
	}
end

return api
