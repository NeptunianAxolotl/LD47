
local util = require("include/util")

local effectDefs = {
	health_down = {
		image = "health_down",
		interface = true,
		alphaScale = true,
		duration = "inherit",
	},
	health_up = {
		image = "health_up",
		interface = true,
		alphaScale = true,
		duration = "inherit",
	},
}


return {
	defs = effectDefs,
}
