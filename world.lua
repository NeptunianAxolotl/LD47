
local Player = require("player")
local Terrain = require("terrainHandler")
local Camaera = require("utilities/cameraUtilities")

local self = {}

function self.Update(dt)
	Terrain.Update(0, 0, dt)
	Player.Update(Terrain, self.cameraX, self.cameraY, dt)
end

function self.Draw()
	Terrain.Draw(0, 0)
	
	local windowX, windowY = love.window.getMode()
	local playerPos, playerVelocity = Player.GetPhysics()
	local gridSize = 128
	
	self.cameraX, self.cameraY = Camaera.UpdateCamera(dt, playerPos, playerVelocity)
	local gridX = -self.cameraX%gridSize
	local gridY = -self.cameraY%gridSize
	
	for i = gridX, gridX + windowX + gridSize, gridSize do
		love.graphics.line(i, 0, i, windowY)
	end
	for i = gridY, gridY + windowY + gridSize, gridSize do
		love.graphics.line(0, i, windowX, i)
	end
	
	Player.Draw(self.cameraX, self.cameraY)
end

function self.Initialize()
	self.cameraX = 0
	self.cameraY = 0
	Player.Initialize()
end

return self