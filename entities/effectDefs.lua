
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
	get_spell_world = {
		image = "get_spell",
		interface = false,
		alphaScale = true,
		color = {0.8, 0.8, 0.5},
		duration = "inherit",
	},
	bunny_bullet_hit = {
		image = "bunny_bullet_hit",
		interface = false,
		alphaScale = true,
		color = {0.5, 0.8, 0.5},
		inFront = 50,
		spawnOffset = {0, -20},
		duration = "inherit",
	},
	ice_hit_effect = {
		image = "bunny_bullet_hit",
		interface = false,
		alphaScale = true,
		color = {0.3, 0.6, 0.9},
		inFront = 50,
		spawnOffset = {0, -12},
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
	dust = {
		image = "dust",
		interface = false,
		alphaScale = true,
		lifeScale = true,
		color = {0.8, 0.8, 0.6},
		spawnOffset = {0, 16},
		inFront = -20,
		duration = "inherit",
	},
	rocket_explode = {
		image = "fireball_explode",
		interface = false,
		alphaScale = true,
		color = {0.8, 0.4, 0.1},
		inFront = 50,
		scale = 0.15,
		spawnOffset = {0, 0},
		duration = "inherit",
	},
	web_explode = {
		image = "fireball_explode",
		interface = false,
		alphaScale = true,
		color = {0.7, 0.8, 0.8},
		inFront = 50,
		scale = 0.08,
		spawnOffset = {0, 0},
		duration = "inherit",
	},
	
	-- Death Clones
	dead_bear = {
		actual_image = "dead_bear",
		interface = false,
		alphaScale = true,
		inFront = 60,
		spawnOffset = {0, 0},
		duration = 10,
	},
	dead_bunny = {
		actual_image = "dead_bunny",
		interface = false,
		alphaScale = true,
		inFront = 60,
		spawnOffset = {0, 0},
		duration = 10,
	},
	dead_spider = {
		actual_image = "dead_spider",
		interface = false,
		alphaScale = true,
		randomDirection = true,
		inFront = 60,
		spawnOffset = {0, 0},
		duration = 10,
	},
	dead_enemy_croc = {
		actual_image = "dead_enemy_croc",
		interface = false,
		alphaScale = true,
		randomDirection = true,
		inFront = 60,
		spawnOffset = {0, 0},
		duration = 10,
	},
	dead_car_red = {
		actual_image = "dead_car_red",
		interface = false,
		alphaScale = true,
		inFront = 60,
		spawnOffset = {0, 50},
		duration = 10,
	},
	dead_car_blue = {
		actual_image = "dead_car_blue",
		interface = false,
		alphaScale = true,
		inFront = 60,
		spawnOffset = {0, 50},
		duration = 10,
	},
}


return {
	defs = effectDefs,
}
