
local util = require("include/util")
local Resources = require("resourceHandler")
local pi = math.pi

local DOWNHILL_DIR = {0, 1}

local self = {}

function self.Update(Terrain, cameraX, cameraY, dt)
	local mouseX = love.mouse.getX() + cameraX
	local mouseY = love.mouse.getY() + cameraY
	
	local mouseVector = util.Unit(util.Subtract({mouseX, mouseY}, self.pos))
	local mouseAngle = util.Angle(mouseVector)
	
	local downhillFactor = util.Dot(self.velocity, DOWNHILL_DIR)
	
	self.velDir = mouseAngle
	self.speed = math.max(0, self.speed + 0.7*downhillFactor*dt)
	self.speed = self.speed - 0.0025*self.speed^1.5
	
	self.velocity = util.Add(util.Mult(0.12 - 0.08*(self.speed/(self.speed + 15)), DOWNHILL_DIR), util.PolarToCart(self.speed, self.velDir))
	self.speed, self.velDir = util.CartToPolar(self.velocity)
	
	self.pos = util.Add(self.pos, self.velocity)
	
	self.faceAngle = self.velDir
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
	self.velDir = pi*3/2
	self.faceAngle = pi*3/2
end

return self