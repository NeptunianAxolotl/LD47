
local util = require("include/util")
local Resources = require("resourceHandler")
local pi = math.pi

local self = {}

function self.Update(Terrain, dt)
	local mouseX = love.mouse.getX()
	local mouseY = love.mouse.getY()
	
	local mouseVector = util.Subtract({mouseX, mouseY}, self.pos)
	local mouseAngle = util.Angle(mouseVector)
	
	self.travelAngle = mouseAngle
	self.speed = 5
	
	self.pos = util.Add(self.pos, util.PolarToCart(self.speed, self.travelAngle))
	
	self.faceAngle = self.travelAngle
end

function self.Draw()
	Resources.DrawIsoImage("test_iso_image", self.pos[1], self.pos[2], self.faceAngle)
end

function self.Initialize()
	self.pos = {0, 0}
	self.speed = 0
	self.travelAngle = pi*3/2
	self.faceAngle = pi*3/2
end

return self