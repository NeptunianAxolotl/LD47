
local spellList = {
    "cantrip",
	"fireball",
	"shotgun",
	"serpent",
	"wisp",
    "haste",
    "seeker",
    "shield",
}

local spellIcon = {
    cantrip = "cantrip_icon",
	fireball = "fireball_icon",
	shotgun  = "shotgun_icon",
	serpent  = "snake_icon",
	wisp     = "wisp_icon",
    haste    = "haste_icon",
    seeker   = "seeker_icon",
    shield   = "shield_icon",
}

local probability = {
    cantrip  = 0,
	fireball = 1,
	shotgun  = 1,
	serpent  = 1,
	wisp     = 1,
    haste    = 1,
    seeker    = 1,
    shield   = 100,
}

return {
	spellList = spellList,
	spellIcon = spellIcon,
	probability = probability,
}
