
local util = require("include/util")
local Font = require("include/font")

local Resources = require("resourceHandler")
local spellDefs = require("spells/spellDefs")
local SpellHandler -- Avoid circular require.

local self = {}
local api = {}

------------------------------------------------------------------
------------------------------------------------------------------

function api.AddScore(cat, value)
	if self.gameOver then
		return
	end
	self.scores[cat] = (self.scores[cat] or 0) + value
end

function api.SetScore(cat, value)
	if self.gameOver then
		return
	end
	self.scores[cat] = value
end

function api.UpdateRecord(cat, value)
	if self.gameOver then
		return
	end
	self.scores[cat] = math.max((self.scores[cat] or 0), value)
end

function api.GetScore(cat)
	return self.scores[cat] or 0
end

function api.SetGameOver()
	self.gameOver = true
end

------------------------------------------------------------------
------------------------------------------------------------------

function api.ShowStats()
	if not self.gameOver then
		return
	end
	self.show = true
end

function api.Update(dt)
	if not self.show then
		return
	end
	self.scoreAlpha = self.scoreAlpha + 1.9*dt
	if self.scoreAlpha > 0.85 then
		self.scoreAlpha = 0.85
	end
end

function api.DrawInterface()
	if not self.show then
		return
	end
	
	local OFF_X = 0.24
	local OFF_Y = 0.14
	
	local windowX, windowY = 1920, 1080
	local alpha = self.scoreAlpha/0.85
	
	love.graphics.setColor(45/255, 85/255, 19/255, self.scoreAlpha)
	love.graphics.rectangle('fill', windowX*OFF_X, windowY*OFF_Y, windowX*(1 - 2*OFF_X), windowY*(1 - 2*OFF_Y))
	
	local PADDING_X = 100
	local PADDING_Y = 68
	local SPELL_SCALE = 0.7
	local OFFSET = 86
	
	local LEFT_POS = windowX*OFF_X + PADDING_X
	local xPos = LEFT_POS
	local yPos = windowY*OFF_Y + PADDING_Y
	
	for i = 1, 8 do
		xPos = LEFT_POS
		
		local spellName = api.GetScore("slot_name" .. i)
		local spellLevel = api.GetScore("slot_level" .. i)
		local spellY = yPos + 22
		
		SpellHandler.DrawSpellLevel({xPos, spellY}, spellLevel, 0, SPELL_SCALE, false, alpha)
		Resources.DrawImage(spellDefs.spellIcon[spellName], xPos, spellY, 0, alpha, SPELL_SCALE)
		
		xPos = xPos + 62
		Font.SetSize(2)
		love.graphics.setColor(1, 1, 0.8, alpha)
		
		love.graphics.print("Level " .. spellLevel .. " " .. spellDefs.humanName[spellName], xPos, yPos)
		
		xPos = xPos + 210
		if spellDefs.statName[spellName] then
			love.graphics.print(math.floor(api.GetScore("spell" .. spellName)) .. spellDefs.statName[spellName], xPos, yPos)
		end
		
		yPos = yPos + OFFSET
	end
	
	
	local LEFT_POS = windowX*0.52 + PADDING_X
	local xPos = LEFT_POS
	local yPos = windowY*OFF_Y + PADDING_Y
	local STAT_OFFSET = 205
	
	Font.SetSize(2)
	love.graphics.setColor(1, 1, 0.8, alpha)
	
	Font.SetSize(1)
	love.graphics.print("Damage Recieved", xPos, yPos - 2)
	yPos = yPos + OFFSET*2/3
	
	Font.SetSize(2)
	love.graphics.print("Projectile", xPos, yPos)
	love.graphics.print(string.format("%d", api.GetScore("projectile_hit")), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Enemy collision", xPos, yPos)
	love.graphics.print(string.format("%d", api.GetScore("enemy_hit")), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Terrain collision", xPos, yPos)
	love.graphics.print(string.format("%d", api.GetScore("terrain_hit")), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Bushes consumed", xPos, yPos)
	love.graphics.print(string.format("%d", api.GetScore("bush_hit")), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	
	yPos = yPos + OFFSET*1/3
	
	Font.SetSize(1)
	love.graphics.print("Progress", xPos, yPos - 2)
	yPos = yPos + OFFSET*2/3
	
	Font.SetSize(2)
	
	love.graphics.print("Rivals defeated", xPos, yPos)
	love.graphics.print(api.GetScore("rivals_defeated"), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Distance to next rival", xPos, yPos)
	love.graphics.print(math.floor(api.GetScore("next_rival_dist")) .. "m", xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Total time", xPos, yPos)
	love.graphics.print(util.SecondsToString(api.GetScore("total_time")), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("First rival time", xPos, yPos)
	love.graphics.print(util.SecondsToString(api.GetScore("first_rival_time"), true), xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	love.graphics.print("Top speed", xPos, yPos)
	love.graphics.print(math.floor(api.GetScore("top_speed")) .. "m/s", xPos + STAT_OFFSET, yPos)
	yPos = yPos + OFFSET*2/3
	
end

function api.Initialize(newSpellHandler)
	self = {
		scores = {},
		scoreAlpha = 0,
		show = false,
	}
	SpellHandler = newSpellHandler
end

return api
