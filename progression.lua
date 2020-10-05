
local SoundHandler = require("soundHandler")

local progression = {}
local self = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

local DISTANCE_SCALE = 30
local PLATEU_MULT = 1.3
local END_SCALE = 11000

local DISTANCE_MULT = 1/1000

local distanceKeyframes = {
	{
		dist          = 0,
		lushFactor    = 1,
		
		spawnCount    = {1, 1},
		spawnTime     = {1, 1},
		obstacleCount = {1, 1},
		spellCount    = {1, 1},
		
		tree_1        = {1, 1},
		rock_1        = {1, 1},
		rock_2        = {1, 1},
		grass_1       = {1, 1},
		grass_2       = {1, 1},
		mud_1         = {1, 1},
		mud_heart     = {1, 1},
		web           = {1, 1},
		
		bunny         = {1, 1},
		rocket_bear   = {1, 1},
		bunny_car     = {1, 1},
		bear_car      = {1, 1},
		spider        = {1, 1},
		croc_enemy    = {1, 1},
		
		cantrip       = {1, 1},
		fireball      = {1, 1},
		shotgun       = {1, 1},
		serpent       = {1, 1},
		wisp          = {1, 1},
		haste         = {1, 1},
		seeker        = {1, 1},
		shield        = {1, 1},
	},
}

local function GetFrames(distance)
	local index = 1
	local first = distanceKeyframes[1]
	local second = distanceKeyframes[1]
	
	while second.dist <= distance do
		index = index + 1
		first = second
		if distanceKeyframes[index] then
			second = distanceKeyframes[index]
		else
			return first, second
		end
	end
	return first, second
end

local function Interpolate(distance)
	local first, second = GetFrames(distance)
	if first.dist == second.dist then
		return first, second, 0
	end
	return first, second, 1 - (distance - first.dist)/(second.dist - first.dist)
end

local function IntAndRand(factor, first, second, name)
	if name == "lushFactor" then
		return factor*first[name] + (1 - factor)*second[name]
	end
	local minInt = factor*first[name][1] + (1 - factor)*second[name][1]
	local maxInt = factor*first[name][2] + (1 - factor)*second[name][2]
	return minInt + math.random()*(maxInt - minInt)
end

function progression.GetBackgroundColor(cameraDistance)
	local first, second, factor = Interpolate(cameraDistance*DISTANCE_MULT)
	
	local lushFactor = IntAndRand(factor, first, second, "lushFactor")/100
	
	local greenScale = math.max(0, math.min(0.4, lushFactor))
	local redScale = math.max(0, math.min(1, lushFactor))

	return {0.95 - 0.3*redScale, 0.8 + 0.2*greenScale, 1}
end

function progression.GetChunkObstacleCount(chunkDistance, Random)
	local first, second, factor = Interpolate(chunkDistance*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, "obstacleCount"))
end

function progression.GetObstacleSpawnWeights(chunkDistance)
	local first, second, factor = Interpolate(chunkDistance*DISTANCE_MULT)
	return {
		tree_1    = IntAndRand(factor, first, second, "tree_1"),
		rock_1    = IntAndRand(factor, first, second, "rock_1"),
		rock_2    = IntAndRand(factor, first, second, "rock_2"),
		grass_1   = IntAndRand(factor, first, second, "grass_1"),
		grass_2   = IntAndRand(factor, first, second, "grass_2"),
		mud_1     = IntAndRand(factor, first, second, "mud_1"),
		mud_heart = IntAndRand(factor, first, second, "mud_heart"),
		web       = IntAndRand(factor, first, second, "web"),
	}
end

function progression.GetChunkSpellCount(chunkDistance, Random)
	local first, second, factor = Interpolate(chunkDistance*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, "spellCount"))
end

function progression.GetSpellSpawnWeights(chunkDistance)
	local first, second, factor = Interpolate(chunkDistance*DISTANCE_MULT)
	return {
		cantrip   = IntAndRand(factor, first, second, "cantrip"),
		fireball  = IntAndRand(factor, first, second, "fireball"),
		shotgun   = IntAndRand(factor, first, second, "shotgun"),
		serpent   = IntAndRand(factor, first, second, "serpent"),
		wisp      = IntAndRand(factor, first, second, "wisp"),
		haste     = IntAndRand(factor, first, second, "haste"),
		seeker    = IntAndRand(factor, first, second, "seeker"),
		shield    = IntAndRand(factor, first, second, "shield"),
	}
end

function progression.GetNextEnemySpawnTime(playerDistance, enemyCount)
	local first, second, factor = Interpolate(playerDistance*DISTANCE_MULT)
	return IntAndRand(factor, first, second, "spawnTime")
end

function progression.GetEnemySpawnCount(playerDistance, enemyCount)
	local first, second, factor = Interpolate(playerDistance*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, "spawnCount"))
end

function progression.GetEnemySpawnWeights(playerDistance, enemyCount)
	local first, second, factor = Interpolate(playerDistance*DISTANCE_MULT)
	return {
		bunny       = IntAndRand(factor, first, second, "bunny"),
		rocket_bear = IntAndRand(factor, first, second, "rocket_bear"),
		bunny_car   = IntAndRand(factor, first, second, "bunny_car"),
		bear_car    = IntAndRand(factor, first, second, "bear_car"),
		spider      = IntAndRand(factor, first, second, "spider"),
		croc_enemy  = IntAndRand(factor, first, second, "croc_enemy"),
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
