
local util = require("include/util")

local creatureDefs = {
	bunny_bullet = {
		imageName = "bullet",
		radius = 16,
		spawnOffset = {0, -25},
		life = 4,
		damage = -1,
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			
		end,
	},
}


return {
	defs = creatureDefs,
}
