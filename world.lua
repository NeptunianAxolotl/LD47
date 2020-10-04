
local Player = require("player")
local Terrain = require("terrainHandler")
local Camera = require("utilities/cameraUtilities")
local DrawOverlappingBackground = require("utilities/backgroundUtilities")
local SpellHandler = require("spellHandler")
local EnemyHandler = require("enemyHandler")

local PriorityQueue = require("include/PriorityQueue")

local IDENTITY_TRANSFORM = love.math.newTransform()

local self = {}

function self.MousePressed()
	SpellHandler.SwapSpell()
end

function self.Update(dt)
	Player.Update(Terrain, EnemyHandler, self.cameraTransform, dt)
	
	local playerPos, playerVelocity, playerSpeed = Player.GetPhysics()
	local cameraX, cameraY, cameraScale = Camera.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed)
	local windowX, windowY = love.window.getMode()
	self.cameraTransform:setTransformation(windowX/2, 150, 0, cameraScale, cameraScale, cameraX, cameraY)
	
	SpellHandler.Update(dt)
	EnemyHandler.Update(Player, dt)
	
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
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	love.graphics.replaceTransform(IDENTITY_TRANSFORM)
	SpellHandler.DrawInterface()
	Player.DrawInterface()
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	Player.Initialize()
	Terrain.Initialize()
end

return self