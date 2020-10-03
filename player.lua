
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
	
	local dirDiff = util.AngleSubtractShortest(mouseAngle, self.velDir)
	self.velDir = self.velDir + util.SignPreserveMax(dirDiff, (self.mouseControlMult or 1)*math.max(0.06, 0.025 + math.sqrt(self.speed)*0.02))
	
	local downhillFactor = util.Dot(self.velocity, DOWNHILL_DIR)
	if downhillFactor < 0 then
		downhillFactor = downhillFactor/10
	end
	
	self.speed = math.max(0, self.speed + 0.012*downhillFactor)
	self.speed = self.speed - 0.0028*self.speed^1.5
	
	self.velocity = util.Add(util.Mult(0.1 - 0.09*(self.speed/(self.speed + 15)), DOWNHILL_DIR), util.PolarToCart(self.speed, self.velDir))
	self.speed, self.velDir = util.CartToPolar(self.velocity)
	
	if self.speed < 8 and util.Dot(self.velocity, DOWNHILL_DIR) < 0 then
		self.mouseControlMult = 0
	elseif self.mouseControlMult and self.speed > 8 then
		self.mouseControlMult = self.mouseControlMult + 0.03
		if self.mouseControlMult > 1 then
			self.mouseControlMult = false
		end
	end
	
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