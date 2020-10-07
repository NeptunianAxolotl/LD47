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
local Progression = require("progression")

local api = {}
local self = {}

local chunkList = {}
local chunkCache = {}

local CHUNK_DRAW_HOR_RANGE = 80
local CHUNK_DRAW_TOP_RANGE = 40
local CHUNK_DRAW_BOT_RANGE = 300 -- stops tall sprites from popping at the bottom of the screen.

local CHUNK_WIDTH = 64 * 32
local CHUNK_HEIGHT = 64 * 32

local rngSeed

local function getExistingChunk(a, b)
	if not chunkCache[b] then
		return
	end
	local hCache = chunkCache[b]
	local cachedVal = hCache[a]
	if cachedVal then
		return cachedVal
	end
	return
end

local function GetNearbyChunks(a, b)
	local offset = ((b%2 == 0) and -1) or 0

	local nearbyChunks = {}
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a - 1, b)
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a + 1, b)
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a + offset, b - 1)
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a + offset + 1, b - 1)
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a + offset, b + 1)
	nearbyChunks[#nearbyChunks + 1] = getExistingChunk(a + offset + 1, b + 1)
	
	return nearbyChunks
end

local function detectCollision(obstacles, otherPos, otherRadius, isCreature, isProjectile, player, dt)
	--Does the circle described by 'x,y,radius' intersect with any
	--of the objects in the 'obstacles' list?
	local collided = false
	for i = 1, #obstacles do
		local v = obstacles[i]
        if v then
            local collide, removeObstacle = v.IsColliding(otherPos, otherRadius, isCreature, isProjectile, player, dt)
            if collide then
                collided = v
            end
            if removeObstacle then
                obstacles[i] = obstacles[#obstacles]
                obstacles[#obstacles] = nil
            end
        end
	end
	return collided
end

local function detectPlacementCollision(a, b, obstacles, colPos, colDef, placeBlockPos, placeBlockRadius)
	--Does the circle described by 'x,y,radius' intersect with any
	--of the objects in the 'obstacles' list?
	for i = 1, #obstacles do
		local v = obstacles[i]
		if v.IsBlockingPlacement(colPos, colDef, placeBlockPos, placeBlockRadius) then
			return true
		end
	end
	if not colDef.chunkEdgePads then
		return
	end
	
	local chunks = GetNearbyChunks(a, b)
	for c = 1, #chunks do
		local chunk = chunks[c]
		for i = 1, #chunk.obstacles do
			local v = chunk.obstacles[i]
			if v.nearChunkEdge and v.IsBlockingPlacement(colPos, colDef, placeBlockPos, placeBlockRadius) then
				return true
			end
		end
	end
end

local function getChunkIDFromPosition(x, y)
	local b = math.floor(y/CHUNK_HEIGHT)
	local a = math.floor((x/CHUNK_WIDTH) - (b%2==0 and 0.5 or 0))
	return a, b
end

local function getChunkIDFromPositionForBothParities(x, y)
	local b = math.floor(y/CHUNK_HEIGHT)
	local a_0 = math.floor((x/CHUNK_WIDTH) - 0.5)
	local a_1 = math.floor(x/CHUNK_WIDTH)
	return a_0, a_1, b
end

local function getChunkPositionFromID(a, b)
	local x = ((b%2==0 and 0.5 or 0)+a)*CHUNK_WIDTH
	local y = b*CHUNK_HEIGHT
	return x, y
end

local function addObstacleToChunk(chunk, obstacleDef, pos)
	chunk.obstacles[#chunk.obstacles + 1] = NewObstacle({pos = pos}, obstacleDef, chunk.rng)
end

local function generateChunk(a, b)
	if not chunkCache[b] then
		chunkCache[b] = {}
	end
	local hCache = chunkCache[b]
	local cachedVal = hCache[a]
	if cachedVal then
		return cachedVal
	end
	
	local rng = love.math.newRandomGenerator(rngSeed+19391*a+16127*b)

	local left, top = getChunkPositionFromID(a, b)
	--Chuncks should be made of tiles+doodads (miminally)
	--Potentially other elements too.
	--Random but repeatable generation using RNG deterministically seeded by a, b, and rngSeed 

	--Generate Obstacles
	local function Random(...)
		return rng:random(...)
	end
	
	local obstacles = {}
	local numObstacles = Progression.GetChunkObstacleCount(top, Random)
	local spellCount = Progression.GetChunkSpellCount(top, Random)

	local spellDistribution = util.WeightsToDistribution(util.TableKeysToList(Progression.GetSpellSpawnWeights(top), ObstacleDefs.spellIndexToKey))
	
	for i = 1, spellCount do
		local obstacleDef = ObstacleDefs.spellSpawnDefs[util.SampleDistribution(spellDistribution, Random)]
		local radius = math.max(obstacleDef.placeBlockRadius, obstacleDef.radius)
		local obstaclePos = {
			left + radius + rng:random()*(CHUNK_WIDTH  - radius*2),
			top + radius + rng:random()*(CHUNK_HEIGHT - radius*2),
		}
		local obstacleSize = (obstacleDef.minSize + rng:random()*(obstacleDef.maxSize - obstacleDef.minSize))
		
		if not detectPlacementCollision(a, b, obstacles, obstaclePos, obstacleDef,
				obstacleDef.placeBlock and util.Add(util.Mult(obstacleSize, obstacleDef.placeBlock[1]), obstaclePos),
				obstacleDef.placeBlock and obstacleDef.placeBlock[2]) then
			obstacles[#obstacles + 1] = NewObstacle({pos = obstaclePos, sizeMult = obstacleSize}, obstacleDef, rng, left, top, CHUNK_WIDTH, CHUNK_HEIGHT)
		end
	end
	
	local spawnDistribution = util.WeightsToDistribution(util.TableKeysToList(Progression.GetObstacleSpawnWeights(top), ObstacleDefs.indexToKey))
	
	for i = 1, numObstacles do
		local obstacleDef = ObstacleDefs.defs[util.SampleDistribution(spawnDistribution, Random)]
		local radius = math.max(obstacleDef.placeBlockRadius, obstacleDef.radius)
		local obstaclePos = {
			left + radius + rng:random()*(CHUNK_WIDTH  - radius*2),
			top + radius + rng:random()*(CHUNK_HEIGHT - radius*2),
		}
		local obstacleSize = (obstacleDef.minSize + rng:random()*(obstacleDef.maxSize - obstacleDef.minSize))
		
		if not detectPlacementCollision(a, b, obstacles, obstaclePos, obstacleDef,
				obstacleDef.placeBlock and util.Add(util.Mult(obstacleSize, obstacleDef.placeBlock[1]), obstaclePos),
				obstacleDef.placeBlock and obstacleDef.placeBlock[2]) then
			obstacles[#obstacles + 1] = NewObstacle({pos = obstaclePos, sizeMult = obstacleSize}, obstacleDef, rng, left, top, CHUNK_WIDTH, CHUNK_HEIGHT)
		end
	end
	
	local chunk = {
		obstacles = obstacles,
		rng = rng,
		left = left,
		top = top,
	}
	hCache[a] = chunk
	
	chunkList[#chunkList + 1] = {a, b}
	return chunk
end

local function getChunksIDsForRegion(top, left, bottom, right)
	local lt_a_0, lt_a_1, lt_b = getChunkIDFromPositionForBothParities(left - CHUNK_DRAW_HOR_RANGE, top - CHUNK_DRAW_BOT_RANGE)
	local rb_a_0, rb_a_1, rb_b = getChunkIDFromPositionForBothParities(right + CHUNK_DRAW_HOR_RANGE, bottom + CHUNK_DRAW_BOT_RANGE)
	
	local chunkIDs = {}
	for b = lt_b, rb_b do
		local lt_a, rb_a = lt_a_0, rb_a_0
		if b%2 ~= 0 then
			lt_a, rb_a = lt_a_1, rb_a_1
		end
		for a = lt_a, rb_a do
			chunkIDs[#chunkIDs+1] = {a, b}
		end
	end
	return chunkIDs
end

function api.GetTerrainCollision(pos, radius, isCreature, isProjectile, player, dt)
	-- Other things, such as the player, enemies, and active spell effects, may call the terrain
	-- to check whether they are colliding with any mechanical part of it.
	--TODO: Additional chunks need to be checked, if the 'radius' overlaps with the edge of the chunk that 'x','y' is in.
	local chunk = getExistingChunk(getChunkIDFromPosition(pos[1], pos[2]))
	if chunk then
		return detectCollision(chunk.obstacles, pos, radius, isCreature, isProjectile, player, dt)
	end
end

function api.AddObstacle(name, pos)
	-- Other things, such as the player, enemies, and active spell effects, may call the terrain
	-- to check whether they are colliding with any mechanical part of it.
	--TODO: Additional chunks need to be checked, if the 'radius' overlaps with the edge of the chunk that 'x','y' is in.
	local chunk = getExistingChunk(getChunkIDFromPosition(pos[1], pos[2]))
	if chunk then
		return addObstacleToChunk(chunk, ObstacleDefs.defs[ObstacleDefs.keyToIndex[name]], pos)
	end
end

local function getChunksForIDs(chunkIDs)
	local chunks = {}
	for i,v in ipairs(chunkIDs) do
		chunks[#chunks+1] = generateChunk(v[1], v[2])
	end
	return chunks
end

local function GetVisibleChunks()
	local left, top = love.graphics.inverseTransformPoint(0,0)
	local right, bottom = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
	local visibleChunkIDs = getChunksIDsForRegion(top, left, bottom, right)
	return getChunksForIDs(visibleChunkIDs)
end

local function DeleteOldChunks()
	local left, top = love.graphics.inverseTransformPoint(0,0)
	local _, _, topChunkIndex = getChunkIDFromPositionForBothParities(left, top)
	
	local newChunkList = {}
	for i = 1, #chunkList do
		local data = chunkList[i]
		if data[2] <= topChunkIndex - 3 then
			if chunkCache[data[2]] then
				chunkCache[data[2]] = nil
			end
		else
			newChunkList[#newChunkList + 1] = data
		end
	end
	
	chunkList = newChunkList
end

local function updateChunk(chunk, dt)
	for i = 1, #chunk.obstacles do
		chunk.obstacles[i].Update(dt)
	end
end

local function updateChunks(visibleChunks, dt)
	--print(#visibleChunks)
	for i, v in ipairs(visibleChunks) do
		updateChunk(v, dt)
	end
end

local function drawChunk(chunk, drawQueue)
	--love.graphics.setColor((chunk.left/1.4)%1, (chunk.left/1.4)%1, (chunk.left/1.4)%1, 0.5)
	--love.graphics.rectangle('fill', chunk.left, chunk.top, CHUNK_WIDTH, CHUNK_HEIGHT)
	for i = 1, #chunk.obstacles do
		chunk.obstacles[i].Draw(drawQueue)
	end
end

local function drawChunks(visibleChunks, drawQueue)
	--print(#visibleChunks)
	for i, v in ipairs(visibleChunks) do
		drawChunk(v, drawQueue)
	end
end

local deleteAcc = 0
function api.Update(dt)
	deleteAcc = deleteAcc + dt
	if deleteAcc > 1 then
		DeleteOldChunks()
		deleteAcc = 0
	end
	
	self.visibleChunks = GetVisibleChunks()
	updateChunks(self.visibleChunks, dt)
end

function api.Draw(drawQueue)
	self.visibleChunks = self.visibleChunks or GetVisibleChunks()
	drawChunks(self.visibleChunks, drawQueue)
end

function api.GetActivity()
	return #chunkList
end

function api.Initialize()
	rngSeed = math.random(0, 2^16)
	self = {}
	
	chunkList = {}
	chunkCache = {}
end

return api
