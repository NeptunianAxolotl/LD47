
local SoundHandler = require("soundHandler")

local progression = {}
local self = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

local DISTANCE_SCALE = 30
local PLATEU_MULT = 1.3
local END_SCALE = 11000

local DISTANCE_MULT = 1/1800

local distanceKeyframes = {
	{
		dist          = -1,
		lushFactor    = 0,
		
		obstacleCount = {0,   0},
		spellCount    = {0,   0},
		
		tree          = {0, 0},
		smallRock     = {3,   7},
		bigRock       = {2,   4},
		grass_1       = {1,   1},
		grass_2       = {1,   1},
		bush          = {0.4, 0.8},
		healthBush    = {0.5, 0.9},
		web           = {0,   0},
		
		spawnTime     = {10,   5},
		spawnCount    = {0,   0},
		
		bunny         = {1,   1},
		rocket_bear   = {0,   0},
		bunny_car     = {0.1,   0},
		bear_car      = {0,   0},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 0,
		lushFactor    = 0,
		
		obstacleCount = {1,   6},
		spellCount    = {0,   0},
		
		tree          = {0, 0},
		smallRock     = {3,   7},
		bigRock       = {2,   4},
		grass_1       = {1,   1},
		grass_2       = {1,   1},
		bush          = {0.4, 0.8},
		healthBush    = {0.5, 0.9},
		web           = {0,   0},
		
		spawnTime     = {10,   5},
		spawnCount    = {0,   0},
		
		bunny         = {1,   1},
		rocket_bear   = {0,   0},
		bunny_car     = {0.1,   0},
		bear_car      = {0,   0},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 1.5,
		lushFactor    = 0,
		
		obstacleCount = {8,   18},
		spellCount    = {1,   1},
		
		tree          = {0, 0},
		smallRock     = {2,   3},
		bigRock       = {2,   5},
		grass_1       = {1,   1},
		grass_2       = {1,   1},
		bush          = {0.4, 0.8},
		healthBush    = {0.5, 0.9},
		web           = {0,   0},
		
		spawnTime     = {12,   5},
		spawnCount    = {1,   2},
		
		bunny         = {1,   1},
		rocket_bear   = {0,   0},
		bunny_car     = {0,   0.05},
		bear_car      = {0,   0},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 6,
		lushFactor    = 6,
		
		obstacleCount = {10,   20},
		spellCount    = {1,   1},
		
		tree          = {0, 0},
		smallRock     = {2,   3},
		bigRock       = {2,   10},
		grass_1       = {1,   1},
		grass_2       = {1,   1},
		bush          = {0.4, 1.5},
		healthBush    = {0.5, 1},
		web           = {0,   0},
		
		spawnTime     = {12,  8},
		spawnCount    = {1,   2},
		
		bunny         = {1,   3},
		rocket_bear   = {0,   0},
		bunny_car     = {0,   1},
		bear_car      = {0,   0},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 18,
		lushFactor    = 18,
		
		obstacleCount = {8,   14},
		spellCount    = {1,   1},
		
		tree          = {1,   2},
		smallRock     = {2,   3},
		bigRock       = {2,   14},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {1,   4},
		healthBush    = {0.9,  3},
		web           = {0,   0},
		
		spawnTime     = {12,   20},
		spawnCount    = {2,   5},
		
		bunny         = {1,   4},
		rocket_bear   = {0,   2},
		bunny_car     = {0,   7},
		bear_car      = {0,   0},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 30,
		lushFactor    = 40,
		
		obstacleCount = {8,   25},
		spellCount    = {1,   2},
		
		tree          = {1,   8},
		smallRock     = {2,   3},
		bigRock       = {1.5, 2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {6,   8},
		spawnCount    = {5,   8},
		
		bunny         = {1,   2},
		rocket_bear   = {0,   3},
		bunny_car     = {1,   5},
		bear_car      = {0,   0.8},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 60,
		lushFactor    = 68,
		
		obstacleCount = {14,   25},
		spellCount    = {1,   2},
		
		tree          = {1,   6},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0.5},
		
		spawnTime     = {10,   15},
		spawnCount    = {5,   30},
		
		bunny         = {0,   0},
		rocket_bear   = {0.2, 4},
		bunny_car     = {3,   8},
		bear_car      = {0.2, 2},
		spider        = {0,   3},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 80,
		lushFactor    = 100,
		
		obstacleCount = {10,   35},
		spellCount    = {1,   2},
		
		tree          = {1,   6},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {5,   10},
		spawnCount    = {8,   12},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   3},
		bunny_car     = {2,   8},
		bear_car      = {0,   3},
		spider        = {0,   1},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 95,
		lushFactor    = 100,
		
		obstacleCount = {2,   35},
		spellCount    = {1.5, 2.5},
		
		tree          = {1,   6},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {10,   15},
		spawnCount    = {10,   20},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   4},
		bunny_car     = {2,   8},
		bear_car      = {0,   3},
		spider        = {0,   0.5},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 110,
		lushFactor    = 50,
		
		obstacleCount = {2,   35},
		spellCount    = {1.5, 2.5},
		
		tree          = {1,   2},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {25,   5},
		spawnCount    = {12,   18},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   4},
		bunny_car     = {2,   8},
		bear_car      = {0,   3},
		spider        = {0,   0.5},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 125,
		lushFactor    = 0,
		
		obstacleCount = {2,   35},
		spellCount    = {1.5, 2.5},
		
		tree          = {1,   2},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {25,   5},
		spawnCount    = {12,   18},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   4},
		bunny_car     = {2,   8},
		bear_car      = {0,   3},
		spider        = {0,   0.5},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 130,
		lushFactor    = 0,
		
		obstacleCount = {5,   12},
		spellCount    = {0, 0},
		
		tree          = {0,   0},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {8,   8},
		spawnCount    = {15,   20},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   1},
		bunny_car     = {0,   1},
		bear_car      = {0,   0.1},
		spider        = {0,   0},
		croc_enemy    = {0,   0},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
	},
	{
		dist          = 150,
		lushFactor    = 0,
		
		obstacleCount = {5,   12},
		spellCount    = {0, 0},
		
		tree          = {0,   0},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {2,   5},
		web           = {0,   0},
		
		spawnTime     = {8,   8},
		spawnCount    = {15,   20},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   1},
		bunny_car     = {0,   1},
		bear_car      = {0,   0.1},
		spider        = {0,   0},
		croc_enemy    = {20,   20},
		
		cantrip       = {0,   0},
		fireball      = {1,   1},
		shotgun       = {1,   1},
		serpent       = {1,   1},
		wisp          = {1,   1},
		haste         = {1,   1},
		seeker        = {1,   1},
		shield        = {1,   1},
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
	local first, second, factor = Interpolate((cameraDistance - (self.resetDist or 0))*DISTANCE_MULT)
	
	local lushFactor = IntAndRand(factor, first, second, "lushFactor")/100
	
	local greenScale = math.max(0, math.min(0.4, lushFactor))
	local redScale = math.max(0, math.min(1, lushFactor))

	return {0.95 - 0.3*redScale, 0.8 + 0.2*greenScale, 1}
end

function progression.GetChunkObstacleCount(chunkDistance, Random)
	local first, second, factor = Interpolate((chunkDistance - (self.resetDist or 0))*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, "obstacleCount"))
end

function progression.GetObstacleSpawnWeights(chunkDistance)
	local first, second, factor = Interpolate((chunkDistance - (self.resetDist or 0))*DISTANCE_MULT)
	return {
		tree_1    = IntAndRand(factor, first, second, "tree"),
		rock_1    = IntAndRand(factor, first, second, "smallRock"),
		rock_2    = IntAndRand(factor, first, second, "bigRock"),
		grass_1   = IntAndRand(factor, first, second, "grass_1"),
		grass_2   = IntAndRand(factor, first, second, "grass_2"),
		mud_1     = IntAndRand(factor, first, second, "bush"),
		mud_heart = IntAndRand(factor, first, second, "healthBush"),
		web       = IntAndRand(factor, first, second, "web"),
	}
end

function progression.GetChunkSpellCount(chunkDistance, Random)
	local first, second, factor = Interpolate((chunkDistance - (self.resetDist or 0))*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, "spellCount"))
end

function progression.GetSpellSpawnWeights(chunkDistance)
	local first, second, factor = Interpolate((chunkDistance - (self.resetDist or 0))*DISTANCE_MULT)
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
	local first, second, factor = Interpolate((playerDistance - (self.resetDist or 0))*DISTANCE_MULT)
	return IntAndRand(factor, first, second, "spawnTime")
end

function progression.GetEnemySpawnCount(playerDistance, enemyCount)
	local first, second, factor = Interpolate((playerDistance - (self.resetDist or 0))*DISTANCE_MULT)
	local count = math.floor(IntAndRand(factor, first, second, "spawnCount"))
	return math.max(count*0.1 , count - 0.7*enemyCount)
end

function progression.GetEnemySpawnWeights(playerDistance, enemyCount)
	local first, second, factor = Interpolate((playerDistance - (self.resetDist or 0))*DISTANCE_MULT)
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
	
	if isDead then
		self.bossHealth = nil
		self.bossMaxHealth = nil
		self.resetDist = self.lastPlayerDist
	end
end

function progression.BossExists()
	return self.bossHealth
end

------------------------------------------------------------------
------------------------------------------------------------------

function progression.Update(playerDistance, dt)
	self.lastPlayerDist = playerDistance -- This is the only line that sees unmodified distances
	playerDistance = playerDistance - (self.resetDist or 0)
	
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
	if self.bossHealth then
		DrawBossHealth()
	end
end

function progression.Initialize()
	self = {}
end

return progression
