
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		speed = 8 * 60,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 700},
		goalRandomOffsetX = 700,
		goalRandomOffsetY = 200,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, def.goalOffset, dt)
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
