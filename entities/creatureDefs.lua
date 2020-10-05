
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")

local SPAWN_OFFSET = {0, 1100}
local OUTER_SPAWN = 1500
local INNER_SPAWN = 1200
local START_ANGLE, END_ANGLE = math.pi*0.2, math.pi*0.8

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		speed = 0.2,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 1000},
		goalRandomOffsetX = 700,
		goalRandomOffsetY = 200,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, def.goalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(INNER_SPAWN, OUTER_SPAWN, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bunny_car",
		imageName = "car",
		turretImage = "bunny",
		health = 50,
		healthRange = 70,
		radius = 58,
		speed = 8,
		maxTurnRate = 0.08,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 700},
		goalRandomOffsetX = 1500,
		goalRandomOffsetY = 300,
		slowTimeMult = 0.2,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*2.3 + 12
			
			local myGoalOffset = util.SetLength(350 + 1500*(playerSpeed/(playerSpeed + 8)), def.goalOffset)
			
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, myGoalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if math.random() < 0.03 and not player.IsDead() then
				local aimVector = util.Subtract(util.Add(util.RandomPointInCircle(80), playerPos), self.pos)
				aimVector[1] = aimVector[1]*0.8 -- Shoot mostly up
				Projectiles.SpawnProjectile("bunny_bullet", self.pos, util.Add(playerVel, util.SetLength(18, aimVector)))
			end
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(INNER_SPAWN, OUTER_SPAWN, START_ANGLE, END_ANGLE))
		end,
	},
}


local indexToKey = {}
for i = 1, #creatureDefs do
	indexToKey[i] = creatureDefs[i].name
end

return {
	defs = creatureDefs,
	indexToKey = indexToKey,
}
