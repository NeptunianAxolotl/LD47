
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")
local EffectHandler = require("effectsHandler")

local START_ANGLE, END_ANGLE = math.pi*0.1, math.pi*0.9

local SPAWN_OFFSET = {0, 800}
local BEAR_SPAWN_OFFSET = {0, 0}

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 50,
		healthRange = 70,
		radius = 32,
		speed = 0.1,
		reloadTime = 10,
		burstRate = 1.8,
		burstCount = 2,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 1000},
		goalRandomOffsetX = 1500,
		goalRandomOffsetY = 200,
		slowTimeMult = 0.6,
		speedChangeFactor = 0.5,
		posChangeFactor = 0.5,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, def.goalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if creatureUtil.UpdateReload(self, def, dt) then
				creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "rocket", 10, 60, 0.15, dt)
			end
		end,
		getSpawnOffset = function(player)
			return util.Add(BEAR_SPAWN_OFFSET, util.RandomPointInAnnulus(2000, 2800, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bunny",
		imageName = "bunny",
		health = 50,
		healthRange = 70,
		radius = 32,
		speed = 0.1,
		reloadTime = 2.8,
		burstRate = 0.1,
		burstCount = 2,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 1000},
		goalRandomOffsetX = 1500,
		goalRandomOffsetY = 200,
		slowTimeMult = 0.6,
		speedChangeFactor = 0.5,
		posChangeFactor = 0.5,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, def.goalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if creatureUtil.UpdateReload(self, def, dt) then
				creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "bunny_bullet", 18, 80, 0.95, dt)
			end
		end,
		getSpawnOffset = function(player)
			return util.Add(BEAR_SPAWN_OFFSET, util.RandomPointInAnnulus(2000, 2800, START_ANGLE, END_ANGLE))
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
		reloadTime = 3,
		burstRate = 0.1,
		burstCount = 4,
		maxTurnRate = 0.32,
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
			
			if creatureUtil.UpdateReload(self, def, dt) then
				creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "bunny_bullet", 18, 80, 0.95, dt)
			end
			
			EffectHandler.SpawnDust(self.pos, self.velocity, self.wantedSpeed, dt, 0.1)
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(1500, 1700, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bear_car",
		imageName = "car_blue",
		turretImage = "bear_car",
		health = 80,
		healthRange = 70,
		radius = 70,
		speed = 8,
		reloadTime = 10,
		burstRate = 1.8,
		burstCount = 1,
		maxTurnRate = 0.32,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 900},
		goalRandomOffsetX = 1800,
		goalRandomOffsetY = 300,
		slowTimeMult = 0.2,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*2.2 + 10
			
			local myGoalOffset = util.SetLength(350 + 1500*(playerSpeed/(playerSpeed + 8)), def.goalOffset)
			
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, myGoalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if creatureUtil.UpdateReload(self, def, dt) then
				creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "rocket", 10, 60, 0.15, dt)
			end
			
			EffectHandler.SpawnDust(self.pos, self.velocity, self.wantedSpeed, dt, 0.1)
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(1800, 2200, START_ANGLE, END_ANGLE))
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
