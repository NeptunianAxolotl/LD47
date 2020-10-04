
local util = require("include/util")
local IterableMap = require("include/IterableMap")

local spellDefs = require("spells/spellDefs")

local Terrain = require("terrainHandler")
local Resources = require("resourceHandler")
local Enemies = require("enemyHandler")

local self = {
	activeSpells = IterableMap.New(),
	spellTypes = {},
	charge = 0,
	spellPositions = {},
	currentSpell = 7, -- Croc starts vertical because it is funny.
	spellAnim = 0,
}

local CHARGE_MULT = 0.11
local SPELL_COUNT = 8
local SPELL_RADIUS = 70
local CROC_CENTRE = 95

local function SpellChargeToAngle()
	local spellData = self.spellPositions[self.currentSpell]
	return spellData.startChargeAngle + self.charge*spellData.chargeProgressRange
end

function self.CastSpell(name, player, world)
	IterableMap.Add(self.activeSpells, self.spellTypes[name](player, world))
end

function self.ReplaceSpell(name)
	self.spellPositions[self.currentSpell].spellName = name
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
	IterableMap.ApplySelf(self.activeSpells, "Update", Terrain, Enemies, dt)
	self.spellAnim = Resources.UpdateAnimation("spell_anim", self.spellAnim, dt)
end

function self.Draw(drawQueue)
	IterableMap.ApplySelf(self.activeSpells, "Draw", drawQueue)
end

function self.DrawInterface()
	Resources.DrawImage("spell_interface", 0, 0)
	for i = 1, SPELL_COUNT do
		local spellData = self.spellPositions[i]
		if i == self.currentSpell then
			Resources.DrawAnimation("spell_anim", spellData.pos[1], spellData.pos[2], self.spellAnim, nil, 0.2 + 0.7*self.charge)
		elseif i%8 + 1 == self.currentSpell and self.charge < 0.1 then
			Resources.DrawAnimation("spell_anim", spellData.pos[1], spellData.pos[2], self.spellAnim, nil, 0.3 - 3*self.charge)
		end
		Resources.DrawImage(spellDefs.spellIcon[spellData.spellName], spellData.pos[1], spellData.pos[2])
	end
	
	Resources.DrawImage("spell_croc", CROC_CENTRE, CROC_CENTRE, SpellChargeToAngle())
end

function self.Initialize()
	local spellCentre = {CROC_CENTRE, CROC_CENTRE}
	for i = 1, SPELL_COUNT do
		local spellData = {
			startChargeAngle = i*math.pi/4,
			chargeProgressRange = 9*math.pi/4,
			spellName = spellDefs.spellList[i%4 + 1],
		}
		spellData.pos = util.Add(spellCentre, util.PolarToCart(SPELL_RADIUS, (i - 1)*math.pi/4))
		
		self.spellPositions[i] = spellData
	end

	for i = 1, #spellDefs.spellList do
		self.spellTypes[spellDefs.spellList[i]] = require("spells/" .. spellDefs.spellList[i])
	end
end

return self
