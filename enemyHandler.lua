
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Terrain = require("terrainHandler")
local CreatureDefs = require("entities/creatureDefs")
local NewCreature = require("entities/creature")

local SPAWN_OFFSET = {0, 400}
local OUTER_SPAWN = 1500
local INNER_SPAWN = 1200
local SPAWN_TIME = 3
local START_ANGLE, END_ANGLE = 0, math.pi

local self = {
	activeEnemies = IterableMap.New(),
	spawnCheckAcc = 0,
}

local function SpawnNewEnemies(player)
	local playerPos, playerVel, playerSpeed = player.GetPhysics()
	
	local spawnCentre = util.Add(playerPos, SPAWN_OFFSET)
	local enemyCount = math.random(3, 6)
	
	local spawnDistribution = util.GenerateDistributionFromBoundedRandomWeights(CreatureDefs.spawnWeights)
	
	for i = 1, enemyCount do
		local creatureDef = CreatureDefs.defs[util.SampleDistribution(spawnDistribution)]
		local creaturePos = util.Add(spawnCentre, util.RandomPointInAnnulus(INNER_SPAWN, OUTER_SPAWN, START_ANGLE, END_ANGLE))
		
		IterableMap.Add(self.activeEnemies, NewCreature({pos = creaturePos}, creatureDef))
	end
end

function self.Update(player, dt)
	self.spawnCheckAcc = self.spawnCheckAcc - dt
	if self.spawnCheckAcc <= 0 then
		SpawnNewEnemies(player)
		self.spawnCheckAcc = SPAWN_TIME
	end

	IterableMap.ApplySelf(self.activeEnemies, "Update", Terrain, player, dt)
end

function self.Draw()
	IterableMap.ApplySelf(self.activeEnemies, "Draw")
end

return self
