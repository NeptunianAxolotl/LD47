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


local self = {}


local TILE_WIDTH = 64
local TILE_HEIGHT = 64

local CHUNK_WIDTH_TILES = 40
local CHUNK_HEIGHT_TILES = 40

local CHUNK_WIDTH = TILE_WIDTH * CHUNK_WIDTH_TILES
local CHUNK_HEIGHT = TILE_HEIGHT * CHUNK_HEIGHT_TILES



local RNG_SEED
function self.Initialize()
	RNG_SEED = math.random(0, 2^16)
end


local function generateChunk(a, b)
	local rng = love.math.newRandomGenerator(RNG_SEED+19391*a+16127*b)

	--Chuncks should be made of tiles+doodads (miminally)
	--Potentially other elements too.
	--Random but repeatable generation using RNG deterministically seeded by a, b, and RNG_SEED 

	return {
		colour = rng:random(),
		left = a*CHUNK_WIDTH,
		top = b*CHUNK_HEIGHT,
	}
end


local function getChunksIDsForRegion(top, left, bottom, right)
	local leftTile = math.floor(left/CHUNK_WIDTH)
	local rightTile = math.ceil(right/CHUNK_WIDTH)
	local topTile = math.floor(top/CHUNK_HEIGHT)
	local bottomTile = math.ceil(bottom/CHUNK_HEIGHT)
	local chunkIDs = {}
	for a = leftTile, rightTile do
		for b = topTile, bottomTile do
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

function self.GetTerrainCollision(x, y, radius)
	-- Other things, such as the player, enemies, and active spell effects, may call the terrain
	-- to check whether they are colliding with any mechanical part of it.
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
	love.graphics.rectangle('fill', chunk.left, chunk.top, CHUNK_WIDTH, CHUNK_HEIGHT)
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