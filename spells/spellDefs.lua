
local spellList = {
    "cantrip",
	"fireball",
	"shotgun",
	"serpent",
	"wisp",
    "haste",
}

local spellIcon = {
    cantrip = "cantrip_icon",
	fireball = "fireball_icon",
	shotgun  = "shotgun_icon",
	serpent  = "snake_icon",
	wisp     = "wisp_icon",
    haste    = "haste_icon",
}

local probability = {
    cantrip  = 0,
	fireball = 1,
	shotgun  = 1,
	serpent  = 1,
	wisp     = 1,
    haste    = 1,
}

return {
	spellList = spellList,
	spellIcon = spellIcon,
	probability = probability,
}
