
local Player = require("player")
local Terrain = require("terrainHandler")
local Camera = require("utilities/cameraUtilities")

local self = {}

function self.Update(dt)
	Terrain.Update(0, 0, dt)
	Player.Update(Terrain, self.cameraTransform, dt)
	local playerPos, playerVelocity = Player.GetPhysics()
	local cameraX, cameraY = Camera.UpdateCamera(dt, playerPos, playerVelocity)
	self.cameraTransform:setTransformation(-cameraX, -cameraY)
end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)
	Terrain.Draw()
	Player.Draw()
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	Player.Initialize()
	Terrain.Initialize()
end

return self