
local progression = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

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
	}
end

function progression.GetChunkSpellCount(chunkDistance, Random)
	return 1
end

function progression.GetSpellSpawnWeights(chunkDistance)
	return {
		cantrip  = 0,
		fireball = 10,
		shotgun  = 1,
		serpent  = 1,
		wisp     = 1,
		haste    = 1,
		seeker   = 1,
		shield   = 1,
	}
end

function progression.GetNextEnemySpawnTime(playerDistance)
	return 4 + math.random()*6
end

function progression.GetEnemySpawnCount(playerDistance)
	return math.random(2, 7)
end

function progression.GetEnemySpawnWeights(playerDistance)
	return {
		rocket_bear = 1,
		bunny_car   = 1,
	}
end

return progression
