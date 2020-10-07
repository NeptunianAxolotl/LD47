
local util = require("include/util")
local IterableMap = require("include/IterableMap")
local Font = require("include/font")

local spellDefs = require("spells/spellDefs")

local Terrain = require("terrainHandler")
local Resources = require("resourceHandler")
local Enemies = require("enemyHandler")
local EffectHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")
local Score = require("score")

local self = {}
local api = {}

local CHARGE_MULT = 0.11
local SPELL_COUNT = 8
local SPELL_RADIUS = 92
local CROC_CENTRE = 125
local SPELL_HELD_POS = {1530, 70}
local HELD_ROTATE = 0.8

local SELECTED_COLOR = {0.8, 0.5, 0.3, 1}

local function SpellChargeToAngle()
	local spellData = self.spellPositions[self.currentSpell]
	return spellData.startChargeAngle + self.charge*spellData.chargeProgressRange
end

function api.SetDead()
	self.isDead = true
end

function api.CastSpell(name, modifiers, level, player)
	IterableMap.Add(self.activeSpells, self.spellTypes[name](player, modifiers, level))
end

function api.MousePressed()
	if self.heldSpell == self.spellPositions[self.currentSpell].spellName then
		api.SwapSpell()
	end
end

function api.SwapSpell()
	if not self.heldSpell then
		return
	end
	if self.heldTutorialCounter == 1 then
		self.heldTutorialCounter = false
	end
	
	local currentSpellData = self.spellPositions[self.currentSpell]
	if currentSpellData.spellName == self.heldSpell then
		currentSpellData.spellLevel = currentSpellData.spellLevel + self.heldSpellLevel
		self.heldSpell, self.heldSpellLevel = false, false
		
		Score.SetScore("slot_level" .. self.currentSpell, currentSpellData.spellLevel)
		return
	end
	
	currentSpellData.spellName, self.heldSpell = self.heldSpell, currentSpellData.spellName
	currentSpellData.spellLevel, self.heldSpellLevel = self.heldSpellLevel, currentSpellData.spellLevel
	
	Score.SetScore("slot_name" .. self.currentSpell, currentSpellData.spellName)
	Score.SetScore("slot_level" .. self.currentSpell, currentSpellData.spellLevel)
	
	EffectHandler.Spawn("switch_spell", SPELL_HELD_POS)
	EffectHandler.Spawn("switch_spell", currentSpellData.pos)
	
	if self.heldSpell == "cantrip" then
		self.heldSpell, self.heldSpellLevel = false, false
	end
end

function api.PickupSpell(name, level)
	self.heldSpell = name
	self.heldSpellLevel = level
	
	EffectHandler.Spawn("get_spell", SPELL_HELD_POS)
	
	if self.heldTutorialCounter then
		self.heldTutorialCounter = 1
	end
end

function api.AddChargeAndCast(player, chargeAdd)
	self.charge = self.charge + chargeAdd*CHARGE_MULT
	if self.charge > 1 then
		local spellData = self.spellPositions[self.currentSpell]
		EffectHandler.Spawn("cast_spell", spellData.pos)
		
		api.CastSpell(spellData.spellName, spellData.modifiers, spellData.spellLevel, player)
		self.charge = self.charge - 1
		self.currentSpell = (self.currentSpell%SPELL_COUNT) + 1
		
		if self.heldSpell == self.spellPositions[self.currentSpell].spellName and not (love.mouse.isDown(1) or love.mouse.isDown(2) or love.mouse.isDown(3)) then
			api.SwapSpell()
		end
	end
end

function api.Update(dt)
	IterableMap.ApplySelf(self.activeSpells, "Update", Terrain, Enemies, dt)
	
	if self.heldSpell then
		self.heldSpellRotate = (self.heldSpellRotate + dt*HELD_ROTATE)%(2*math.pi)
	else
		self.heldSpellRotate = 0
	end
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.activeSpells, "Draw", drawQueue)
end

function api.DrawSpellLevel(pos, level, rotation, scale, selected, alpha)
	if level <= 3 then
		Resources.DrawImage("shape_" .. (level + 2), pos[1], pos[2], rotation, alpha, scale, selected and SELECTED_COLOR)
		return
	end
	
	local nests = {}
	while level > 3 do
		Resources.DrawImage("shape_5", pos[1], pos[2], rotation, alpha, scale, selected and SELECTED_COLOR)
		scale = scale*0.81
		level = level - 3
	end
	
	Resources.DrawImage("shape_" .. (level + 2), pos[1], pos[2], rotation, alpha, scale, selected and SELECTED_COLOR)
end

function api.DrawInterface()
	Resources.DrawImage("spell_interface", 1920 - 340, 0)
	for i = 1, SPELL_COUNT do
		local spellData = self.spellPositions[i]
		api.DrawSpellLevel(spellData.pos, spellData.spellLevel, spellData.rotation, 1, i == self.currentSpell)
		Resources.DrawImage(spellDefs.spellIcon[spellData.spellName], spellData.pos[1], spellData.pos[2])
	end
	
	if self.heldSpell then
		api.DrawSpellLevel(SPELL_HELD_POS, self.heldSpellLevel, self.heldSpellRotate, 1.3)
		Resources.DrawImage(spellDefs.spellIcon[self.heldSpell], SPELL_HELD_POS[1], SPELL_HELD_POS[2], 0, 1.3)
	end
	
	if self.heldTutorialCounter == 1 and not self.isDead then
		Font.SetSize(0)
		love.graphics.setColor(1, 0.1, 0)
		love.graphics.print("You grabbed a spell! Click to swap it into the loop.", 500, 25)
	end
	
	Resources.DrawImage("spell_croc", 1920 - CROC_CENTRE, CROC_CENTRE, SpellChargeToAngle())
end

function api.GetActivity()
	return IterableMap.Count(self.activeSpells)
end

function api.Initialize()
	self = {
		activeSpells = IterableMap.New(),
		spellTypes = {},
		charge = 0,
		spellPositions = {},
		currentSpell = 7, -- Croc starts vertical because it is funny.
		heldSpell = false,
		heldSpellLevel = false,
		heldSpellRotate = 0,
		heldTutorialCounter = 0,
	}
	local spellCentre = {1920 - CROC_CENTRE, CROC_CENTRE}
	for i = 1, SPELL_COUNT do
		local toOut = util.PolarToCart(SPELL_RADIUS, (i - 1)*math.pi/4)
		local spellData = {
			startChargeAngle = i*math.pi/4,
			chargeProgressRange = 9*math.pi/4,
			spellName = "cantrip",
			spellLevel = 1,
			modifiers = {},
			rotation = (i + 5)*math.pi/4,
		}
		spellData.pos = util.Add(spellCentre, toOut)
		
		Score.SetScore("slot_name" .. i, spellData.spellName)
		Score.SetScore("slot_level" .. i, spellData.spellLevel)
		
		self.spellPositions[i] = spellData
	end

	for i = 1, #spellDefs.spellList do
		self.spellTypes[spellDefs.spellList[i]] = require("spells/" .. spellDefs.spellList[i])
	end
end

return api
