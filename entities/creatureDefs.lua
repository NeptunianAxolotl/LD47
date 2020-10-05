
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		speed = 8,
		minSpawnWeight = 5,
		maxSpawnWeight = 10,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 700},
		goalRandomOffsetX = 700,
		goalRandomOffsetY = 200,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, def.goalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
		end
	},
	{
		name = "bunny_car",
		imageName = "car",
		health = 50,
		healthRange = 70,
		radius = 48,
		speed = 8 ,
		maxTurnRate = 0.08,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 700},
		goalRandomOffsetX = 900,
		goalRandomOffsetY = 300,
		slowTimeMult = 0.5,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*1.8 + 12
			
			local myGoalOffset = util.SetLength(350 + 1400*(playerSpeed/(playerSpeed + 8)), def.goalOffset)
			
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, myGoalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end
	},
}

local spawnWeights = {}
for i = 1, #creatureDefs do
	spawnWeights[i] = {
		creatureDefs[i].minSpawnWeight,
		creatureDefs[i].maxSpawnWeight,
	}
end

return {
	defs = creatureDefs,
	spawnWeights = spawnWeights,
}
