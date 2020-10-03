
local obstacleDefs = {
	{
		name = "tree_1",
		imageName = "tree_1",
		health = 50,
		healthRange = 70,
		placeRadius = 110,
		placeBlockRadius = 50,
		radius = 32,
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
	{
		name = "rock_2",
		imageName = "rock_2",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 50,
		radius = 70,
		minSpawnWeight = 2,
		maxSpawnWeight = 15,
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
