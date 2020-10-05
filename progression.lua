
local SoundHandler = require("soundHandler")

local progression = {}
local self = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

local DISTANCE_SCALE = 30000
local PLATEU_MULT = 1.3
local END_SCALE = 11000

function progression.GetBackgroundColor(cameraDistance)
	local greenScale = math.max(0, math.min(DISTANCE_SCALE*0.4, cameraDistance))/(DISTANCE_SCALE*0.4)
	local redScale = math.max(0, math.min(DISTANCE_SCALE, cameraDistance))/DISTANCE_SCALE
	
	if cameraDistance > DISTANCE_SCALE*PLATEU_MULT then
		-- Rapidly go backwards.
		factor = math.max(0, math.min(1, (END_SCALE - (cameraDistance - DISTANCE_SCALE*PLATEU_MULT))/END_SCALE))
		
		greenScale = factor
		redScale = factor
	end

	return {0.95 - 0.3*redScale, 0.8 + 0.2*greenScale, 1}
end

function progression.GetChunkObstacleCount(chunkDistance, Random)
	return Random(OBSTACLES_PER_CHUNK_MIN, OBSTACLES_PER_CHUNK_MAX)
end

function progression.GetObstacleSpawnWeights(chunkDistance)
	return {
		tree_1    = 1,
		rock_1    = 1,
		rock_2    = 1,
		grass_1   = 1,
		grass_2   = 1,
		mud_1     = 1,
		mud_heart = 1,
		web       = 0,
	}
end

function progression.GetChunkSpellCount(chunkDistance, Random)
	return 1
end

function progression.GetSpellSpawnWeights(chunkDistance)
	return {
		cantrip  = 0,
		fireball = 1,
		shotgun  = 1,
		serpent  = 1,
		wisp     = 1,
		haste    = 1,
		seeker   = 1,
		shield   = 1,
	}
end

function progression.GetNextEnemySpawnTime(playerDistance, enemyCount)
	return 200 + math.random()*100
end

function progression.GetEnemySpawnCount(playerDistance, enemyCount)
	return math.random(1, 2)
end

function progression.GetEnemySpawnWeights(playerDistance, enemyCount)
	return {
		rocket_bear = 1,
		bunny_car   = 1,
		bear_car    = 1,
		bunny       = 1,
		spider      = 1,
		croc_enemy  = 1000,
	}
end

------------------------------------------------------------------
------------------------------------------------------------------
-- Boss

local function DrawBossHealth()
	local windowX, windowY = love.window.getMode()
	
	local OFF_X = 0.22
	local OFF_Y = 0.87
	local HEIGHT = 0.05
	
	self.bossAlpha = self.bossAlpha or 0
	
	love.graphics.setColor(0, 0, 0, self.bossAlpha)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle('line', windowX*OFF_X, windowY*OFF_Y, windowX*(1 - 2*OFF_X), windowY*HEIGHT)

	local otherCol = math.max(0, (self.bossAlpha - 0.5)*0.8)

	love.graphics.setColor(1, otherCol, otherCol, self.bossAlpha)
	love.graphics.rectangle('fill', windowX*OFF_X + 1.5, windowY*OFF_Y + 1.5,
		windowX*(1 - 2*OFF_X)*self.bossHealth/self.bossMaxHealth - 3, windowY*HEIGHT - 3)
	
	love.graphics.setLineWidth(1)
end

function progression.SetBossHealth(newHealth, isDead, maxHealth)
	if self.bossHealth and self.bossHealth ~= newHealth then
		self.bossAlpha = 0.95
	end
	
	self.bossHealth = newHealth
	self.bossMaxHealth = maxHealth or self.bossMaxHealth or newHealth
	self.bossIsDead = isDead
end

function progression.BossExists()
	return self.bossHealth and not self.bossIsDead
end

------------------------------------------------------------------
------------------------------------------------------------------

function progression.Update(playerDistance, dt)
	if not self.musicPlaying then
		SoundHandler.PlaySound("fulltrack", true)
		self.musicPlaying = true
	end
	if self.bossAlpha then
		if self.bossAlpha > 0.5 then
			self.bossAlpha = self.bossAlpha - dt*0.7
			if self.bossAlpha < 0.5 then
				self.bossAlpha = 0.5
			end
		else
			self.bossAlpha = self.bossAlpha + dt*0.5
		end
	end
	
end

function progression.DrawInterface()
	if self.bossHealth and not self.bossIsDead then
		DrawBossHealth()
	end
end

function progression.Initialize()
	self = {}
end

return progression
