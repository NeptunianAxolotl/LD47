
local util = require("include/util")
local creatureUtil = require("entities/creatureUtilities")
local EffectHandler = require("effectsHandler")

local START_ANGLE, END_ANGLE = math.pi*0.2, math.pi*0.8

local SPAWN_OFFSET = {0, 800}
local BEAR_SPAWN_OFFSET = {0, 500}

local creatureDefs = {
	{
		name = "rocket_bear",
		imageName = "rocket_bear",
		health = 200,
		healthRange = 100,
		radius = 32,
		speed = 0.1,
		reloadTime = 10,
		burstRate = 1.8,
		burstCount = 2,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 1000},
		goalRandomOffsetX = 1200,
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
			return util.Add(BEAR_SPAWN_OFFSET, util.RandomPointInAnnulus(2400, 3200, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bunny",
		imageName = "bunny",
		health = 60,
		healthRange = 20,
		radius = 32,
		speed = 0.1,
		reloadTime = 2.8,
		burstRate = 0.1,
		burstCount = 2,
		despawnDistance = 500,
		stopRange = 10,
		goalOffset = {0, 1000},
		goalRandomOffsetX = 1200,
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
			return util.Add(BEAR_SPAWN_OFFSET, util.RandomPointInAnnulus(2400, 3200, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bunny_car",
		imageName = "car",
		turretImage = "bunny",
		health = 60,
		healthRange = 20,
		radius = 58,
		speed = 8,
		reloadTime = 3,
		burstRate = 0.1,
		burstCount = 4,
		maxTurnRate = 0.32,
		despawnDistance = 500,
		turnLimit = 3.2,
		goalOffset = {0, 700},
		goalRandomOffsetX = 1200,
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
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(1800, 2400, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "bear_car",
		imageName = "car_blue",
		turretImage = "bear_car",
		health = 150,
		healthRange = 50,
		radius = 65,
		speed = 8,
		reloadTime = 7,
		burstRate = 1.8,
		burstCount = 1,
		maxTurnRate = 0.32,
		despawnDistance = 500,
		turnLimit = 2.8,
		goalOffset = {0, 900},
		goalRandomOffsetX = 1000,
		goalRandomOffsetY = 300,
		slowTimeMult = 0.2,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*2.2 + 14
			
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
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(1800, 2400, START_ANGLE, END_ANGLE))
		end,
	},
	{
		name = "spider",
		animationName = "spider",
		health = 100,
		healthRange = 50,
		radius = 60,
		speed = 0.1,
		drawInFront = 60,
		reloadTime = 4,
		burstRate = 0.25,
		burstCount = 3,
		despawnDistance = 500,
		maxTurnRate = 0.32,
		turnLimit = 2.8,
		goalOffset = {0, 600},
		goalRandomOffsetX = 1400,
		goalRandomOffsetY = 500,
		slowTimeMult = 0.2,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*1.7 + 20
			
			local myGoalOffset = util.SetLength(350 + 1500*(playerSpeed/(playerSpeed + 8)), def.goalOffset)
			
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, myGoalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if creatureUtil.UpdateReload(self, def, dt) then
				creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "spider_web", math.random()*6 + 2.5, 450, 1.1, dt)
			end
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(BEAR_SPAWN_OFFSET, util.RandomPointInAnnulus(1800, 2400, math.pi*0.4, math.pi*0.6))
		end,
	},
	{
		name = "croc_enemy",
		animationName = "croc_enemy",
		animateWithSpeed = true,
		isBoss = true,
		recolor = {1, 0.4, 1},
		health = 15000,
		healthRange = 50,
		radius = 40,
		speed = 8,
		reloadTime = 2,
		burstRate = 0.28,
		burstCount = 4,
		maxTurnRate = 0.24,
		turnLimit = 1.9,
		goalOffset = {0, 200},
		goalRandomOffsetX = 800,
		goalRandomOffsetY = 600,
		slowTimeMult = 0.2,
		speedChangeFactor = 0.7,
		posChangeFactor = 0.3,
		updateFunc = function (self, def, Terrain, Enemies, Projectiles, player, dt)
			local playerPos, playerVel, playerSpeed = player.GetPhysics()
			self.wantedSpeed = playerSpeed*3 + 10
			
			self.goalChangeTime = (self.goalChangeTime or 1) - dt
			if self.goalChangeTime < 0 then
				self.goalChangeTime = self.goalChangeTime + 5
				self.randomGoalOffset = util.RandomPointInEllipse(def.goalRandomOffsetX, def.goalRandomOffsetY)
			end
			
			local myGoalOffset = util.SetLength(350 + 1500*(playerSpeed/(playerSpeed + 8)), def.goalOffset)
			
			creatureUtil.MoveTowardsPlayer(self, def, Terrain, Enemies, player, def.stopRange, myGoalOffset, dt)
			creatureUtil.DoCollisions(self, def, Terrain, Enemies, player, dt)
			
			if creatureUtil.UpdateReload(self, def, dt) then
				if not self.projectileType then
					self.projectileType = math.random()*4
				end
				
				if self.projectileType < 1 then
					creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "fireball", 18, 60, 0.75, dt)
				elseif self.projectileType < 2 then
					creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "spider_web", math.random()*6 + 2.5, 450, 1.1, dt)
				elseif self.projectileType < 3 then
					for i = 1, 9 do
						creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "ice", 22, 6000, 1, dt)
					end
				else
					creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "bees", 3, 60, 0.15, dt)
					creatureUtil.ShootBulletAtPlayer(self, Projectiles, player, "bees", 3, 60, 0.15, dt)
				end
				
				if self.fireCycle%2 == 0 then
					self.projectileType = false
					self.projectileSpeed = false
				end
			end
			
			EffectHandler.SpawnDust(self.pos, self.velocity, self.wantedSpeed, dt, 0.8)
			
			creatureUtil.SetLimitedTurnDrawDir(self, def, dt)
		end,
		getSpawnOffset = function(player)
			return util.Add(SPAWN_OFFSET, util.RandomPointInAnnulus(1800, 2400, START_ANGLE, END_ANGLE))
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
