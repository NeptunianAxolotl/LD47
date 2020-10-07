
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

local spellObstacleAnim = {
	cantrip  = "spell_anim",
	fireball = "spell_anim_fire",
	shotgun  = "spell_anim",
	serpent  = "spell_anim_serpent",
	wisp     = "spell_anim_wisp",
	haste    = "spell_anim_haste",
	seeker   = "spell_anim_seeker",
	shield   = "spell_anim_shield",
}

local humanName = {
	cantrip  = "Cantrip",
	fireball = "Fireball",
	shotgun  = "Ice Shards",
	serpent  = "Serpent",
	wisp     = "Energy Orb",
	haste    = "Haste",
	seeker   = "Busy Bee",
	shield   = "Shield",
}

local statName = {
	cantrip  = " damage",
	fireball = " damage",
	shotgun  = " damage",
	serpent  = " damage",
	wisp     = " damage",
	haste    = false,
	seeker   = " damage",
	shield   = " blocked"
}

return {
	spellList = spellList,
	spellIcon = spellIcon,
	spellObstacleAnim = spellObstacleAnim,
	humanName = humanName,
	statName = statName,
}
