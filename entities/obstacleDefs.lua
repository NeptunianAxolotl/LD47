
local util = require("include/util")
local spellDefs = require("spells/spellDefs")

local obstacleDefs = {
	{
		name = "tree_1",
		imageName = "tree_1",
		health = 50,
		healthRange = 40,
		placeRadius = 110,
		placeBlockRadius = 50,
		radius = 32,
		collideCreature = true,
        collideProjectile = true,
        projectileCalc = function(projEffect)
            if projEffect and projEffect.fire and projEffect.fire > 0 then
                return projEffect.fire
            else
                return 0
            end
        end,
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
		collideProjectile = true,
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
		collideProjectile = true,
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
		overlapEffect = function (self, player, distSq, dt)
			local _, _, playerSpeed = player.GetPhysics()
			if playerSpeed > 6 then
				playerSpeed = playerSpeed*(1 - 60*dt*0.07)
				player.SetSpeed(playerSpeed)
			end
			if not self.imageOverride then
				player.ModifyHealth(1)
			end
			self.imageOverride = "bush_1_flat"
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

local spellSpawnDefs = {}
for i = 1, #spellDefs.spellList do
	local spellName = spellDefs.spellList[i]
	spellSpawnDefs[i] = {
		name = "spell_" .. i,
		imageName = spellDefs.spellIcon[spellName],
		spellName = spellName,
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 120,
		radius = 70,
		scale = 1.7,
		collideCreature = false,
		minSpawnWeight = spellDefs.probability[spellName],
		maxSpawnWeight = spellDefs.probability[spellName],
	}
end

local spellSpawnWeights = {}
for i = 1, #spellSpawnDefs do
	spellSpawnWeights[i] = {
		spellSpawnDefs[i].minSpawnWeight,
		spellSpawnDefs[i].maxSpawnWeight,
	}
end

return {
	defs = obstacleDefs,
	spawnWeights = spawnWeights,
	spellSpawnDefs = spellSpawnDefs,
	spellSpawnWeights = spellSpawnWeights,
}
