--Not sure which graphical elements are here and which are elsewhere
	--Stateless{
	--Major tiles (Grass, Ice, Snow, Water, Leaves, Road, River, etc) (Non-overlapping; potentially affect player physics (speed, friction, turn rate, etc))
	--Connecting/blending tiles (Breaks up straight lines in borders between major tiles)
	--Decals (Makes tile edges more distinct (e.g. for edges of roads), or adds visual interest (e.g. piles of leaves, moss, pebbles, patches of dirt, etc))
	--}
	--Possibly Stateful/Affected by Player{
	--Doodads (can these be flattened (etc.) by the player? e.g. small shrubs, tufts of grass, small piles of snow, vines?)
	--Obstacles (maybe not done in this function; since they are not purely graphical)
	--Player trail(?)
	--Player; enemies; spells
--}

local util = require("include/util")
local ObstacleDefs = require("entities/obstacleDefs")
local NewObstacle = require("entities/obstacle")

local self = {}


local chunkCache = {}

local TILE_WIDTH = 64
local TILE_HEIGHT = 64

local CHUNK_WIDTH_TILES = 40
local CHUNK_HEIGHT_TILES = 40

local CHUNK_DRAW_HOR_RANGE = 80
local CHUNK_DRAW_RANGE = 300 -- stops tall sprites from popping at the bottom of the screen.

local CHUNK_WIDTH = TILE_WIDTH * CHUNK_WIDTH_TILES
local CHUNK_HEIGHT = TILE_HEIGHT * CHUNK_HEIGHT_TILES

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

local RNG_SEED
function self.Initialize()
	RNG_SEED = math.random(0, 2^16)
end

local function detectCollision(obstacles, otherPos, otherRadius, isCreature, isProjectile, player, dt)
	--Does the circle described by 'x,y,radius' intersect with any
	--of the objects in the 'obstacles' list?
	local collided = false
	for i = 1, #obstacles do
		local v = obstacles[i]
		local collide, removeObstacle = v.IsColliding(otherPos, otherRadius, isCreature, isProjectile, player, dt)
		if collide then
			collided = v
		elseif removeObstacle then
			obstacles[i] = obstacles[#obstacles]
			obstacles[#obstacles] = nil
		end
	end
	return collided
end

local function detectPlacementCollision(obstacles, colPos, colDef)
	--Does the circle described by 'x,y,radius' intersect with any
	--of the objects in the 'obstacles' list?
	for i = 1, #obstacles do
		local v = obstacles[i]
		if v.IsBlockingPlacement(colPos, colDef) then
			return true
		end
	end
end

local function getChunkIDFromPosition(x, y)
	local b = math.floor(y/CHUNK_HEIGHT)
	local a = math.floor((x/CHUNK_WIDTH) - (b%2==0 and 0.5 or 0))
	return a, b
end

local function getChunkPositionFromID(a, b)
	local x = ((b%2==0 and 0.5 or 0)+a)*CHUNK_WIDTH
	local y = b*CHUNK_HEIGHT
	return x, y
end

local function generateChunk(a, b)
	if not chunkCache[a] then
		chunkCache[a] = {}
	end
	local hCache = chunkCache[a]
	local cachedVal = hCache[b]
	if cachedVal then
		return cachedVal
	end
	
	local rng = love.math.newRandomGenerator(RNG_SEED+19391*a+16127*b)

	local left, top = getChunkPositionFromID(a, b)
	--Chuncks should be made of tiles+doodads (miminally)
	--Potentially other elements too.
	--Random but repeatable generation using RNG deterministically seeded by a, b, and RNG_SEED 

	--Generate Obstacles
	
	local obstacles = {}
	local numObstacles = rng:random(OBSTACLES_PER_CHUNK_MIN, OBSTACLES_PER_CHUNK_MAX)
	
	local spawnDistribution = util.GenerateDistributionFromBoundedRandomWeights(ObstacleDefs.spawnWeights)
	
	for i = 1, numObstacles do
		local obstacleDef = ObstacleDefs.defs[util.SampleDistribution(spawnDistribution)]
		local radius = math.max(obstacleDef.placeBlockRadius, obstacleDef.radius)
		local obstaclePos = {
			left + radius + rng:random()*(CHUNK_WIDTH  - radius*2),
			top + radius + rng:random()*(CHUNK_HEIGHT - radius*2),
		}
		
		if not detectPlacementCollision(obstacles, obstaclePos, obstacleDef) then
			obstacles[#obstacles + 1] = NewObstacle({pos = obstaclePos}, obstacleDef)
		end
	end
	
	local chunk = {
		colour = rng:random(),
		left = left,
		top = top,
		obstacles = obstacles,
	}
	hCache[b] = chunk
	return chunk
end


local function getChunksIDsForRegion(top, left, bottom, right)
	local lt_a, lt_b = getChunkIDFromPosition(left - CHUNK_DRAW_HOR_RANGE, top - CHUNK_DRAW_HOR_RANGE)
	local rb_a, rb_b = getChunkIDFromPosition(right, bottom + CHUNK_DRAW_RANGE)

	local chunkIDs = {}
	for a = lt_a-1, rb_a+1 do
		for b = lt_b, rb_b do
			chunkIDs[#chunkIDs+1] = {a; b}
		end
	end
	return chunkIDs
end

function self.Update(playerX, playerY, dt)
	-- Creates and removes mechanical obstacles as well as graphical things based on
	-- player position. Things may use dt to animate or otherwise do stuff (like a tree burning down).
	
	-- Include and deal with individual behaviours for dynamic feature (a burning tree, an exploding bomb etc..) here.
end

function self.GetTerrainCollision(pos, radius, isCreature, isProjectile, player, dt)
	-- Other things, such as the player, enemies, and active spell effects, may call the terrain
	-- to check whether they are colliding with any mechanical part of it.
	--TODO: Additional chunks need to be checked, if the 'radius' overlaps with the edge of the chunk that 'x','y' is in.
	return detectCollision(generateChunk(getChunkIDFromPosition(pos[1], pos[2])).obstacles, pos, radius, isCreature, isProjectile, player, dt)
end

function self.GetTerrainBiome(x, y)
	--Grass/Rivers/Roads/Lavaflows/Snow/Ice etc could all have different physics properties for the player/spells/enemies.
end

local function getChunksForIDs(chunkIDs)
	local chunks = {}
	for i,v in ipairs(chunkIDs) do
		chunks[#chunks+1] = generateChunk(v[1], v[2])
	end
	return chunks
end

local function drawChunk(chunk)
	love.graphics.setColor(chunk.colour, chunk.colour, chunk.colour)
	love.graphics.setColor(100/255, 153/255, 0)
	love.graphics.rectangle('fill', chunk.left, chunk.top, CHUNK_WIDTH, CHUNK_HEIGHT)
	love.graphics.setColor(1, 0, 1)
	for i = 1, #chunk.obstacles do
		chunk.obstacles[i].Draw()
	end
end

local function drawChunks(visibleChunks)
	for i, v in ipairs(visibleChunks) do
		drawChunk(v)
	end
end

function self.Draw()
	local left, top = love.graphics.inverseTransformPoint(0,0)
	local right, bottom = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
	local visibleChunkIDs = getChunksIDsForRegion(top, left, bottom, right)
	local visibleChunks = getChunksForIDs(visibleChunkIDs)
	drawChunks(visibleChunks)
end

return self
