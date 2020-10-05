
local util = require("include/util")
local EffectHandler = require("effectsHandler")

local creatureDefs = {
	bunny_bullet = {
		animationName = "bullet",
		radius = 16,
		spawnOffset = {0, -36},
		life = 3.5,
		damage = -1,
		hitEffect = "bunny_bullet_hit",
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			
		end,
	},
	rocket = {
		animationName = "rocket",
		radius = 24,
		spawnOffset = {0, -90},
		life = 4,
		damage = -1,
		hitRadius = 200,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			if not self.init then
				self.init = true
				self.ignoreTerrain = 1.8
			end
			if self.ignoreTerrain then
				self.ignoreTerrain = self.ignoreTerrain - dt
				if self.ignoreTerrain < 0 then
					self.ignoreTerrain = false
				end
			end
			
			local playerPos, playerVelocity, playerSpeed = player.GetPhysics()
			local toPlayer = util.Subtract(util.Add(util.Mult(35, playerVelocity), playerPos), self.pos)
			
			self.velocity = util.Add(util.Mult(1 - dt*0.8, self.velocity), util.SetLength(24*dt, toPlayer))
			self.speed, self.direction = util.CartToPolar(self.velocity)
			if self.speed < 11 then
				self.speed = 11
				self.velocity = util.SetLength(self.speed, self.velocity)
			end
		end,
		onKill = function (self, def, Terrain, Enemies, player, dt)
			EffectHandler.Spawn("rocket_explode", self.pos)
			local playerPos, playerVelocity, playerSpeed = player.GetPhysics()
			if util.DistVectors(playerPos, self.pos) < def.hitRadius then
				player.ModifyHealth(-1)
			end
		end,
	},
	spider_web = {
		imageName = "web_shot",
		radius = 24,
		spawnOffset = {0, -10},
		life = 1.2,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			
		end,
		onKill = function (self, def, Terrain, Enemies, player, dt)
			EffectHandler.Spawn("web_explode", self.pos)
			Terrain.AddObstacle("web", self.pos)
		end,
	},
}


return {
	defs = creatureDefs,
}
