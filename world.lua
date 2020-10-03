
local Player = require("player")
local Terrain = require("terrainHandler")
local Camera = require("utilities/cameraUtilities")
local SpellHandler = require("spellHandler")

local self = {}

function self.Update(dt)
	Terrain.Update(0, 0, dt)
	Player.Update(Terrain, self.cameraTransform, dt)
	
	local playerPos, playerVelocity, playerSpeed = Player.GetPhysics()
	local cameraX, cameraY, cameraScale = Camera.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed)
	local windowX, windowY = love.window.getMode()
	self.cameraTransform:setTransformation(windowX/2, 150, 0, cameraScale, cameraScale, cameraX, cameraY)
	
	SpellHandler.Update(dt)
end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)
	Terrain.Draw()
	Player.Draw()
	SpellHandler.Draw()
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	Player.Initialize()
	Terrain.Initialize()
end

return self