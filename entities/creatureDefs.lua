
local util = require("include/util")

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
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
