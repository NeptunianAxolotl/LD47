
local SoundHandler = require("soundHandler")

local progression = {}
local self = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

local DISTANCE_SCALE = 30
local PLATEU_MULT = 1.3
local END_SCALE = 11000

local DISTANCE_MULT = 1/1800

local BOSS_DISTANCE = 130

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
		bush          = {0.1, 0.6},
		healthBush    = {0.1, 0.6},
		web           = {0,   0},
		
		spawnTime     = {10,   5},
		spawnCount    = {0,   0},
		
		bunny         = {1,   1},
		rocket_bear   = {0,   0},
		bunny_car     = {0, 0.1},
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
		bush          = {0.1, 0.6},
		healthBush    = {0.1, 0.6},
		web           = {0,   0},
		
		spawnTime     = {10,   5},
		spawnCount    = {0,   0},
		
		bunny         = {1,   1},
		rocket_bear   = {0,   0},
		bunny_car     = {0,   0.1},
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
		bush          = {0.1, 0.6},
		healthBush    = {0.1, 0.6},
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
		healthBush    = {0.9,  2},
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
		bigRock       = {1.5, 5},
		grass_1       = {1,   4},
		grass_2       = {1,   4},
		bush          = {2,   6},
		healthBush    = {0.2, 1},
		web           = {0,   0},
		
		spawnTime     = {6,   8},
		spawnCount    = {5,   8},
		
		bunny         = {1,   2},
		rocket_bear   = {0.5,   3},
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
		dist          = 68,
		lushFactor    = 68,
		
		obstacleCount = {14,   25},
		spellCount    = {1,   2},
		
		tree          = {4,   8},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   6},
		healthBush    = {0.2, 1},
		web           = {0,   0.5},
		
		spawnTime     = {10,   15},
		spawnCount    = {5,   28},
		
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
		
		obstacleCount = {14,  45},
		spellCount    = {1,   2},
		
		tree          = {1,   6},
		smallRock     = {1,   2},
		bigRock       = {1.5,   2},
		grass_1       = {2,   3},
		grass_2       = {2,   3},
		bush          = {3,   8},
		healthBush    = {1,   2},
		web           = {0,   0},
		
		spawnTime     = {5,   10},
		spawnCount    = {10,  28},
		
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
		dist          = 100,
		lushFactor    = 100,
		
		obstacleCount = {2,   35},
		spellCount    = {1.5, 2.5},
		
		tree          = {4,   10},
		smallRock     = {2,   3},
		bigRock       = {1.5,   2},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {2,   9},
		healthBush    = {1,   2},
		web           = {0,   0},
		
		spawnTime     = {10,   15},
		spawnCount    = {10,   15},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   4},
		bunny_car     = {2,   8},
		bear_car      = {0,   3},
		spider        = {0,   1.5},
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
		smallRock     = {2,   6},
		bigRock       = {1.5, 8},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {1,   4},
		healthBush    = {0.5, 1},
		web           = {0,   0},
		
		spawnTime     = {25,  5},
		spawnCount    = {20,  32},
		
		bunny         = {0,   0},
		rocket_bear   = {0,   4},
		bunny_car     = {2,   8},
		bear_car      = {0,   2.5},
		spider        = {0,   1.5},
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
		dist          = 120,
		lushFactor    = 0,
		
		obstacleCount = {2,   35},
		spellCount    = {1.5, 2.5},
		
		tree          = {1,   2},
		smallRock     = {2,   6},
		bigRock       = {1.5, 8},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {1,   4},
		healthBush    = {0.5, 1},
		web           = {0,   0},
		
		spawnTime     = {25,   5},
		spawnCount    = {12,   20},
		
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
		dist          = 122,
		lushFactor    = 0,
		
		obstacleCount = {5,   12},
		spellCount    = {0, 0},
		
		tree          = {1,   2},
		smallRock     = {2,   6},
		bigRock       = {1.5, 8},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {1,   4},
		healthBush    = {0.5, 1},
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
		dist          = BOSS_DISTANCE,
		lushFactor    = 0,
		
		obstacleCount = {5,   12},
		spellCount    = {0, 0},
		
		tree          = {0.5,   1},
		smallRock     = {2,   6},
		bigRock       = {1.5, 8},
		grass_1       = {1,   3},
		grass_2       = {1,   3},
		bush          = {1,   4},
		healthBush    = {0.2, 1},
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
	count = count*(self.spawnMult or 1)
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
-- Loop

local function UpdateLoop()
	self.loops = (self.loops or 0) + 1
	self.healthMult = (self.healthMult or 1)*1.5
	self.spawnMult  = (self.spawnMult or 1) + 0.2
	
	self.resetDist = self.lastPlayerDist
end

function progression.GetHealthMult()
	return self.healthMult or 1
end

function progression.GetProgressStats()
	local bossDist = ((self.resetDist or 0) + BOSS_DISTANCE/DISTANCE_MULT) - (self.lastPlayerDist or 0)
	return bossDist, self.loops or 0
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
		UpdateLoop()
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
       self.introTimer = 18.146
       self.musicPlaying = true
       self.musicTrack = 1
       self.wantedMusicTrack = 1
       SoundHandler.PlaySound("crocodial_a", false, "0", 0.5, 0, 1)
       SoundHandler.PlaySound("crocodial_b", true, "1", 1, 18.146, 20)
    end
    self.introTimer = self.introTimer - dt
    if self.introTimer < 0 then
        if not self.loopTimer then self.loopTimer = 12.170 end
        self.loopTimer = self.loopTimer - dt
        if self.loopTimer < 0 then self.loopTimer = self.loopTimer + 12.170 end
        if (not progression.BossExists()) and (playerDistance*DISTANCE_MULT <= BOSS_DISTANCE * 0.66) and self.wantedMusicTrack ~= 1 then
            self.wantedMusicTrack = 1
            SoundHandler.PlaySound("crocodial_b", true, "1", 1, self.loopTimer, 20)
        end
        if (not progression.BossExists()) and (playerDistance*DISTANCE_MULT > BOSS_DISTANCE * 0.66) and self.wantedMusicTrack ~= 2 then
            self.wantedMusicTrack = 2
            SoundHandler.PlaySound("crocodial_c", true, "2", 1, self.loopTimer, 20)
        end
        if progression.BossExists() and self.wantedMusicTrack ~= 3 then
            self.wantedMusicTrack = 3
            SoundHandler.PlaySound("crocodial_d", true, "3", 1, self.loopTimer, 20)
        end
        if self.loopTimer < 0.2 and self.musicTrack ~= self.wantedMusicTrack then
            if self.musicTrack == 1 then SoundHandler.StopSound("crocodial_b1", true) end
            if self.musicTrack == 2 then SoundHandler.StopSound("crocodial_c2", true) end
            if self.musicTrack == 3 then SoundHandler.StopSound("crocodial_d3", true) end
            self.musicTrack = self.wantedMusicTrack
        end
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
