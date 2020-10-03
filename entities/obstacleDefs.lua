
local obstacleDefs = {
	{
		name = "tree_1",
		imageName = "tree_1",
		health = 50,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 25,
		radius = 18,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
	},
	{
		name = "rock_1",
		imageName = "rock_1",
		health = 50,
		healthRange = 70,
		placeRadius = 40,
		placeBlockRadius = 10,
		radius = 30,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
	},
}

local spawnWeights = {}
for i = 1, #obstacleDefs do
	spawnWeights[i] = {
		obstacleDefs[i].minSpawnWeight,
		obstacleDefs[i].maxSpawnWeight,
	}
end

return {
	defs = obstacleDefs,
	spawnWeights = spawnWeights,
}
