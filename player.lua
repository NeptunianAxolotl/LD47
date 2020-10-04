
local util = require("include/util")
local Font = require("include/font")

local Resources = require("resourceHandler")
local SpellHandler = require("spellHandler")
local pi = math.pi

local DOWNHILL_DIR = {0, 1}

local HEALTH_SPACING = 58
local DIST_TO_KM = 1/15000

local self = {}
local api = {}

local healthImages = {
	"health_none",
	"health_half",
	"health_full",
}

local function ModifyHealth(change)
	if self.isDead then
		return
	end
	self.health = math.max(0, math.min(6, self.health + change))
	if self.health == 0 then
		self.isDead = true
		self.velocity = {0, 0}
		self.speed = 0
		SpellHandler.SetDead()
	end
end

local function UpdatePhysics(mouseX, mouseY, dt)
	local mouseVector = util.Unit(util.Subtract({mouseX, mouseY}, self.pos))
	local mouseAngle = util.Angle(mouseVector)
	
	local dirDiff = util.AngleSubtractShortest(mouseAngle, self.velDir)
	local dirChange = dt*60*math.abs(util.AngleSubtractShortest(self.velDir, self.prevVelDir or self.velDir))
	self.prevVelDir = self.velDir
	
	local mouseControl = (self.mouseControlMult or 1)
	if self.stunTime then
		self.stunTime = self.stunTime - dt
		if self.stunTime > 0 then
			mouseControl = mouseControl*0.5
		else
			self.stunTime = false
		end
	end
	
	local maxTurnRate = dt*60*math.min(0.085, 0.05 + math.sqrt(self.speed)*0.0185)
	self.velDir = self.velDir + util.SignPreserveMax(dirDiff, mouseControl*maxTurnRate)
	
	local downhillFactor = util.Dot(self.velocity, DOWNHILL_DIR)
	if downhillFactor < 0 then
		downhillFactor = downhillFactor/10
	end
	
	self.speed = math.max(0, self.speed + dt*60*0.012*downhillFactor + ((self.speedMult or 1) - 1)*7*dt)
	self.speed = math.max(0, self.speed - dt*60*(0.0032*self.speed^1.5 + 0.06*self.speed*dirChange^3))
	
	self.velocity = util.Add(util.Mult(dt*60*(0.1 - 0.09*(self.speed/(self.speed + 15))), DOWNHILL_DIR), util.PolarToCart(self.speed, self.velDir))
	self.speed, self.velDir = util.CartToPolar(self.velocity)
	
	if self.speed < 8 and util.Dot(self.velocity, DOWNHILL_DIR) < 0 then
		self.mouseControlMult = 0.4
	elseif self.mouseControlMult and self.speed > 8 then
		self.mouseControlMult = self.mouseControlMult + 0.02
		if self.mouseControlMult > 1 then
			self.mouseControlMult = false
		end
	end
	
	self.speedMult = false
end

local function DoCollision(other, typeMult, dt)
	local otherPos, otherRadius = other.GetPhysics()
	
	local toOther = util.Unit(util.Subtract(otherPos, self.pos))
	local toOtherAngle = util.Angle(toOther)
	
	local severityFactor = util.Dot(toOther, util.Unit(util.Add(self.velocity, DOWNHILL_DIR)))*typeMult
	if severityFactor < 0 then
		return
	end
	
	local damageSeverity = (0.6*severityFactor + 0.4)*self.speed*(typeMult*0.5 + 0.5)
	
	self.stunTime = severityFactor*2
	
	local newVelocity = util.ReflectVector(self.velocity, toOtherAngle + pi/2 + (math.random()*0.8*severityFactor - 0.4*severityFactor))
	if typeMult >= 1 then
		self.velocity = newVelocity
	else
		self.velocity = util.Average(self.velocity, newVelocity, typeMult)
	end
	self.velocity = util.Add(self.velocity, util.Mult(-1*(severityFactor + 0.1), toOther))

	self.speed = (1 - math.max(0.2, math.min(0.7, severityFactor)))*self.speed + 3*severityFactor
	
	if other.AddPosition then
		other.AddPosition(util.Mult(severityFactor*3 + 0.5*self.speed, toOther))
	end
	
	if severityFactor > 0.95 then
		self.speed = self.speed + 3
		if toOther[1] > 0 then
			self.velocity = util.Add(self.velocity, {2, 0})
		else
			self.velocity = util.Add(self.velocity, {-2, 0})
		end
	end
	
	self.velocity = util.SetLength(self.speed, self.velocity)
	self.velDir = util.Angle(self.velocity)
	
	--print("Ouch severity", damageSeverity, self.speed)
	if damageSeverity > 16 then
		ModifyHealth(-2)
	elseif damageSeverity > 10 then
		ModifyHealth(-1)
	end
end

local function CheckTerrainCollision(Terrain, dt)
	local collide = Terrain.GetTerrainCollision(self.pos, self.radius, true, false, api, dt)
	if not collide then
		return
	end
	
	DoCollision(collide, 1, dt)
end

local function CheckEnemyCollision(EnemyHandler, dt)
	local collide = EnemyHandler.DetectCollision(self.pos, self.radius, false, false, api, dt)
	if not collide then
		return
	end
	
	DoCollision(collide, 0.45, dt)
end

local function UpdateFacing(dt)
	local dirDiff = util.AngleSubtractShortest(self.velDir, self.facingDir)
	if self.stunTime then
		self.facingDir = self.facingDir + util.SignPreserveMax(dirDiff, dt*60*0.18)
	else
		self.facingDir = self.facingDir + util.SignPreserveMax(dirDiff, dt*60*2)
	end
end

local function UpdateSpellcasting(dt)
	SpellHandler.AddChargeAndCast(api, world, dt * (self.speed + 3))
end

function api.PickupSpell(spellName, spellLevel)
	SpellHandler.PickupSpell(spellName, spellLevel)
end

function api.SetSpeedMult(speedMult)
	self.speedMult = math.max(self.speedMult or 1, speedMult)
end

function api.IsDead()
	return self.isDead
end

function api.Update(Terrain, EnemyHandler, cameraTransform, dt)
	local mouseX, mouseY = cameraTransform:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
	
	if self.isDead then
		self.animProgress = Resources.UpdateAnimation("stun", self.animProgress, dt)
		return
	end
	
	UpdatePhysics(mouseX, mouseY, dt)
	CheckTerrainCollision(Terrain, dt)
	CheckEnemyCollision(EnemyHandler, dt)
	
	self.pos = util.Add(self.pos, util.Mult(dt*60, self.velocity))
	UpdateFacing(dt)
	
	UpdateSpellcasting(dt)
	
	self.animProgress = Resources.UpdateAnimation("croc", self.animProgress, dt*(self.speed + 1)/12)
end

function api.GetPhysics()
	return self.pos, self.velocity, self.speed
end


function api.SetSpeed(speed)
	self.speed = speed
	self.velocity = util.SetLength(self.speed, self.velocity)
end

local function DrawHealth()
	local healthLimit = -1
	
	for i = 1, 3 do
		local heartVal = math.max(1, math.min(3, (self.health - healthLimit)))
		Resources.DrawImage(healthImages[heartVal], 10 + (i - 1)*HEALTH_SPACING, 10)
		healthLimit = healthLimit + 2
	end
end

function api.DrawInterface()
	Resources.DrawImage("status_interface", 0, 0)
	DrawHealth()
	
	Font.SetSize(2)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Distance " .. (string.format("%.1f", math.floor(self.pos[2]*10*DIST_TO_KM)/10)) .. "km", 8, 10 + HEALTH_SPACING + 14)
	love.graphics.print("Speed " .. (string.format("%.0f", math.floor(self.speed*60*1000*DIST_TO_KM))) .. "m/s", 8, 10 + HEALTH_SPACING + 14 + 26)
	
	if self.isDead then
		Font.SetSize(1)
		love.graphics.setColor(1, 0.1, 0)
		love.graphics.print("Whoops! Press 'r' to restart.", 460, 25)
	end
end

function api.Draw(drawQueue)
	if not self.isDead then
		drawQueue:push({y=self.pos[2]; f=function() Resources.DrawIsoAnimation("croc", self.pos[1], self.pos[2], self.animProgress, self.facingDir) end})
		return
	end
	drawQueue:push({y=self.pos[2] + 200; f = function()
		Resources.DrawImage("dead_croc", self.pos[1], self.pos[2], self.facingDir)
		Resources.DrawAnimation("stun", self.pos[1], self.pos[2], self.animProgress)
	end})
end

function api.Initialize()
	self = {
		radius = 8,
		stunTime = false,
		animProgress = 0,
		health = 6,
		pos = {0, 0},
		velocity = {0, 2},
		speed = 2,
		velDir = pi/2,
		facingDir = pi/2,
	}
end

return api