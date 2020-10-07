
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
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = true,
        collideProjectile = true,
        projectileCalc = function(projEffect)
            if projEffect and projEffect.fire and projEffect.fire > 0 then
                return projEffect.fire
            else
                return 0
            end
        end,
	},
	{
		name = "rock_1",
		imageName = "rock_1",
		health = 50,
		healthRange = 70,
		placeRadius = 40,
		placeBlockRadius = 10,
		radius = 30,
		minSize = 0.9,
		maxSize = 1.5,
		collideCreature = true,
		collideProjectile = false,
	},
	{
		name = "rock_2",
		imageName = "rock_2",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 60,
		radius = 70,
		minSize = 0.4,
		maxSize = 1.2,
		collideCreature = true,
		collideProjectile = true,
	},
	{
		name = "grass_1",
		imageName = "grass_1",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 50,
		radius = 30,
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = false,
		collideProjectile = false,
	},
	{
		name = "grass_2",
		imageName = "grass_2",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 50,
		radius = 30,
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = false,
		collideProjectile = false,
	},
	{
		name = "mud_1",
		imageName = "bush_1",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 80,
		radius = 70,
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = false,
		collideProjectile = false,
		overlapEffect = function (self, player, distSq, dt)
			local _, _, playerSpeed = player.GetPhysics()
			if playerSpeed > 8 then
				playerSpeed = playerSpeed*(1 - 60*dt*0.02)
				player.SetSpeed(playerSpeed)
			end
			self.imageOverride = "bush_1_flat"
		end,
	},
	{
		name = "mud_heart",
		imageName = "bush_hearts",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 80,
		radius = 70,
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = false,
		collideProjectile = false,
		overlapEffect = function (self, player, distSq, dt)
			local _, _, playerSpeed = player.GetPhysics()
			if playerSpeed > 8 then
				playerSpeed = playerSpeed*(1 - 60*dt*0.02)
				player.SetSpeed(playerSpeed)
			end
			if not self.imageOverride then
				player.ModifyHealth(1, "bush_hit")
			end
			self.imageOverride = "bush_1_flat"
		end,
	},
	{
		name = "web",
		imageName = "web",
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 80,
		radius = 160,
		drawInFront = -800,
		minSize = 0.85,
		maxSize = 1.15,
		collideCreature = false,
		collideProjectile = false,
		overlapEffect = function (self, player, distSq, dt)
			local _, _, playerSpeed = player.GetPhysics()
			if playerSpeed > 6 then
				playerSpeed = playerSpeed*(1 - 60*dt*0.04)
				player.SetSpeed(playerSpeed)
			end
		end,
	},
}


local spellSpawnDefs = {}
for i = 1, #spellDefs.spellList do
	local spellName = spellDefs.spellList[i]
	spellSpawnDefs[i] = {
		name = spellName,
		imageName = spellDefs.spellIcon[spellName],
		spellName = spellName,
		spellAnim = spellDefs.spellObstacleAnim[spellName],
		health = 80,
		healthRange = 70,
		placeRadius = 80,
		placeBlockRadius = 120,
		radius = 70,
		minSize = 1,
		maxSize = 1,
		scale = 1.7,
		collideCreature = false,
	}
end

local indexToKey = {}
local keyToIndex = {}
for i = 1, #obstacleDefs do
	indexToKey[i] = obstacleDefs[i].name
	keyToIndex[obstacleDefs[i].name] = i
end

local spellIndexToKey = {}
for i = 1, #spellSpawnDefs do
	spellIndexToKey[i] = spellSpawnDefs[i].name
end

return {
	defs = obstacleDefs,
	indexToKey = indexToKey,
	keyToIndex = keyToIndex,
	spellSpawnDefs = spellSpawnDefs,
	spellIndexToKey = spellIndexToKey,
}
