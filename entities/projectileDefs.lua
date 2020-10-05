
local util = require("include/util")

local creatureDefs = {
	bunny_bullet = {
		imageName = "bullet",
		radius = 2,
		spawnOffset = {0, -15},
		updateFunc = function (self, def, Terrain, Enemies, player, dt)
			
		end,
	},
}


return {
	defs = creatureDefs,
}
