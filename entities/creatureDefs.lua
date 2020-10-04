
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		minSpawnWeight = 10,
		maxSpawnWeight = 30,
		updateFunc = function (self, Terrain, player, dt)
			local playerPos = player.GetPhysics()
			self.direction = util.Angle(util.Subtract(playerPos, self.pos))
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
