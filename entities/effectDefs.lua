
local util = require("include/util")

local effectDefs = {
	-- Interface
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
	get_spell = {
		image = "get_spell",
		interface = true,
		alphaScale = true,
		color = {0.8, 0.8, 0.5},
		duration = "inherit",
	},
	switch_spell = {
		image = "get_spell",
		interface = true,
		alphaScale = true,
		color = {0.5, 0.8, 0.8},
		duration = "inherit",
	},
	cast_spell = {
		image = "spell_anim",
		interface = true,
		alphaScale = true,
		duration = "inherit",
	},
	switch_spell = {
		image = "get_spell",
		interface = true,
		alphaScale = true,
		color = {0.5, 0.8, 0.8},
		duration = "inherit",
	},
	
	-- World
	bunny_bullet_hit = {
		image = "bunny_bullet_hit",
		interface = false,
		alphaScale = true,
		color = {0.5, 0.8, 0.5},
		inFront = 50,
		spawnOffset = {0, -20},
		duration = "inherit",
	},
	fireball_explode = {
		image = "fireball_explode",
		interface = false,
		alphaScale = true,
		color = {0.8, 0.4, 0.1},
		inFront = 50,
		spawnOffset = {0, 0},
		duration = "inherit",
	},
}


return {
	defs = effectDefs,
}
