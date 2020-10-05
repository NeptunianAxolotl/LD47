
local progression = {}

local OBSTACLES_PER_CHUNK_MIN = 18
local OBSTACLES_PER_CHUNK_MAX = 50

function progression.GetChunkObstacleCount(top, Random)
	return Random(OBSTACLES_PER_CHUNK_MIN, OBSTACLES_PER_CHUNK_MAX)
end

function progression.GetObstacleSpawnWeights(top)
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

function progression.GetChunkSpellCount(top, Random)
	return 1
end

function progression.GetSpellSpawnWeights(top)
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



return progression
