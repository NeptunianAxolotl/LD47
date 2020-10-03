
local util = require("include/util")
local Resources = require("resourceHandler")
local pi = math.pi

local self = {}

function self.Update(Terrain, cameraX, cameraY, dt)
	local mouseX = love.mouse.getX() + cameraX
	local mouseY = love.mouse.getY() + cameraY
	
	local mouseVector = util.Subtract({mouseX, mouseY}, self.pos)
	local mouseAngle = util.Angle(mouseVector)
	
	self.travelAngle = mouseAngle
	self.speed = 5
	
	self.velocity = util.PolarToCart(self.speed, self.travelAngle)
	self.pos = util.Add(self.pos, self.velocity)
	
	self.faceAngle = self.travelAngle
end

function self.GetPhysics()
	return self.pos, self.velocity
end

function self.Draw(xOffset, yOffset)
	Resources.DrawIsoImage("test_iso_image", self.pos[1] - xOffset, self.pos[2] - yOffset, self.faceAngle)
end

function self.Initialize()
	self.pos = {500, 0}
	self.velocity = {0, 0}
	self.speed = 0
	self.travelAngle = pi*3/2
	self.faceAngle = pi*3/2
end

return self