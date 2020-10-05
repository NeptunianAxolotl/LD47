
local Player = require("player")
local Terrain = require("terrainHandler")
local ProjectileHandler = require("projectileHandler")
local Camera = require("utilities/cameraUtilities")
local DrawOverlappingBackground = require("utilities/backgroundUtilities")
local SpellHandler = require("spellHandler")
local EnemyHandler = require("enemyHandler")
local EffectsHandler = require("effectsHandler")

local PriorityQueue = require("include/PriorityQueue")

local self = {}

function self.MousePressed()
	SpellHandler.SwapSpell()
end

function self.Update(dt)
	Player.Update(Terrain, EnemyHandler, self.cameraTransform, dt)
	
	local playerPos, playerVelocity, playerSpeed = Player.GetPhysics()
	local cameraX, cameraY, cameraScale = Camera.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed, Player.IsDead() and 0.96 or 0.85)
	local windowX, windowY = love.window.getMode()
	self.cameraTransform:setTransformation(windowX/2, 160 + (1 - cameraScale)*60, 0, cameraScale*windowY/1080, cameraScale*windowY/1080, cameraX, cameraY)
	
	SpellHandler.Update(dt)
	EnemyHandler.Update(Player, dt)
	ProjectileHandler.Update(Player, dt)
	EffectsHandler.Update(dt)
	
	-- Only update visible chunks.
	love.graphics.replaceTransform(self.cameraTransform)
	Terrain.Update(dt)
end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)
	DrawOverlappingBackground()
	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)
	Terrain.Draw(drawQueue)
	Player.Draw(drawQueue)
	SpellHandler.Draw(drawQueue)
	EnemyHandler.Draw(drawQueue)
	ProjectileHandler.Draw(drawQueue)
	EffectsHandler.Draw(drawQueue)
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	local windowX, windowY = love.window.getMode()
	self.interfaceTransform:setTransformation(0, 0, 0, windowX/1920, windowX/1920, 0, 0)
	love.graphics.replaceTransform(self.interfaceTransform)
	SpellHandler.DrawInterface()
	Player.DrawInterface()
	EffectsHandler.DrawInterface()
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	Camera.Initialize()
	Player.Initialize()
	Terrain.Initialize()
	EffectsHandler.Initialize()
	SpellHandler.Initialize()
	EnemyHandler.Initialize()
	ProjectileHandler.Initialize()
end

return self