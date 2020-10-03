
local util = require("include/util")
local Resources = require("resourceHandler")
local pi = math.pi

local DOWNHILL_DIR = {0, 1}

local self = {}

function self.Update(Terrain, cameraTransform, dt)
	local mouseX, mouseY = cameraTransform:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
	
	local mouseVector = util.Unit(util.Subtract({mouseX, mouseY}, self.pos))
	local mouseAngle = util.Angle(mouseVector)
	
	local dirDiff = util.AngleSubtractShortest(mouseAngle, self.velDir)
	local dirChange = math.abs(util.AngleSubtractShortest(self.velDir, self.prevVelDir or self.velDir))
	self.prevVelDir = self.velDir
	
	local maxTurnRate = math.min(0.085, 0.035 + math.sqrt(self.speed)*0.02)
	self.velDir = self.velDir + util.SignPreserveMax(dirDiff, (self.mouseControlMult or 1)*maxTurnRate)
	
	local downhillFactor = util.Dot(self.velocity, DOWNHILL_DIR)
	if downhillFactor < 0 then
		downhillFactor = downhillFactor/10
	end
	
	self.speed = math.max(0, self.speed + 0.012*downhillFactor)
	self.speed = self.speed - 0.0025*self.speed^1.5 - 0.05*self.speed*dirChange^3
	
	self.velocity = util.Add(util.Mult(0.1 - 0.09*(self.speed/(self.speed + 15)), DOWNHILL_DIR), util.PolarToCart(self.speed, self.velDir))
	self.speed, self.velDir = util.CartToPolar(self.velocity)
	
	if self.speed < 8 and util.Dot(self.velocity, DOWNHILL_DIR) < 0 then
		self.mouseControlMult = 0.4
	elseif self.mouseControlMult and self.speed > 8 then
		self.mouseControlMult = self.mouseControlMult + 0.02
		if self.mouseControlMult > 1 then
			self.mouseControlMult = false
		end
	end
	
	self.pos = util.Add(self.pos, self.velocity)
	
	self.faceAngle = self.velDir
end

function self.GetPhysics()
	return self.pos, self.velocity, self.speed
end

function self.Draw()
	Resources.DrawIsoImage("test_iso_image", self.pos[1], self.pos[2], self.faceAngle)
end

function self.Initialize()
	self.pos = {0, 0}
	self.velocity = {0, 2}
	self.speed = 2
	self.velDir = pi/2
	self.faceAngle = pi/2
end

return self