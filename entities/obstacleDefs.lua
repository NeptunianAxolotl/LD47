
local util = require("include/util")

local obstacleDefs = {
	{
		name = "tree_1",
		imageName = "tree_1",
		health = 50,
		healthRange = 70,
		placeRadius = 110,
		placeBlockRadius = 50,
		radius = 32,
		collideCreature = true,
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
		collideCreature = true,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
	},
	{
		name = "rock_2",
		imageName = "rock_2",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 60,
		radius = 70,
		collideCreature = true,
		minSpawnWeight = 2,
		maxSpawnWeight = 15,
	},
	{
		name = "grass_1",
		imageName = "grass_1",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 50,
		radius = 30,
		collideCreature = false,
		minSpawnWeight = 8,
		maxSpawnWeight = 20,
	},
	{
		name = "mud_1",
		imageName = "bush_1",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 80,
		radius = 70,
		collideCreature = false,
		overlapEffect = function (self, player, centreDist, dt)
			if player.speed > 6 then
				player.speed = player.speed*(1 - 60*dt*0.07)
				player.velocity = util.SetLength(player.speed, player.velocity)
			end
		end,
		minSpawnWeight = 10,
		maxSpawnWeight = 20,
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
