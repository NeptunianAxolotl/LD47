
local IterableMap = require("include/IterableMap")
local Terrain = require("terrainHandler")
local Resources = require("resourceHandler")

local self = {
	activeSpells = IterableMap.New(),
	spellTypes = {},
	charge = 0,
	spellPositions = {},
	currentSpell = 7, -- Croc starts vertical because it is funny.
}

local CHARGE_MULT = 0.1
local SPELL_COUNT = 8
local CROC_CENTRE = 95

local spellList = {
	"fireball",
	"shotgun",
	"serpent",
	"wisp"
}

local function SpellChargeToAngle()
	local spellData = self.spellPositions[self.currentSpell]
	return spellData.startChargeAngle + self.charge*spellData.chargeProgressRange
end

function self.CastSpell(name, player, world)
	IterableMap.Add(self.activeSpells, self.spellTypes[name](player, world))
end

function self.AddChargeAndCast(player, world, chargeAdd)
	self.charge = self.charge + chargeAdd*CHARGE_MULT
	if self.charge > 1 then
		self.CastSpell(self.spellPositions[self.currentSpell].spellName, player, world)
		self.charge = self.charge - 1
		self.currentSpell = (self.currentSpell%SPELL_COUNT) + 1
	end
end

function self.Update(dt)
	IterableMap.ApplySelf(self.activeSpells, "Update", Terrain, dt)
end

function self.Draw()
	IterableMap.ApplySelf(self.activeSpells, "Draw")
end

function self.DrawInterface()
	Resources.DrawImage("spell_interface", 0, 0)
	Resources.DrawImage("spell_croc", CROC_CENTRE, CROC_CENTRE, SpellChargeToAngle())
end

function self.Initialize()
	local spellCentre = {CROC_CENTRE, CROC_CENTRE}
	for i = 1, SPELL_COUNT do
		self.spellPositions[i] = {
			startChargeAngle = i*math.pi/4,
			chargeProgressRange = 9*math.pi/4,
			spellName = spellList[i%4 + 1],
		}
	end

	for i = 1, #spellList do
		self.spellTypes[spellList[i]] = require("spells/" .. spellList[i])
	end
end

return self
