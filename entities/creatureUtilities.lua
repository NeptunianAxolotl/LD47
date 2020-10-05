
local util = require("include/util")

local creatureUtils = {}

local function Collision(self, def, other, collideMult, dt)
	local otherPos, otherRadius = other.GetPhysics()
	local toOther = util.Subtract(otherPos, self.pos)
	local otherDist = util.AbsVal(toOther)
	local collideIntensity = ((otherRadius + def.radius) - otherDist + 50)*0.003 + 0.001
	if otherDist < (otherRadius + def.radius)*0.6 then
		collideIntensity = collideIntensity + 0.9*(otherRadius + def.radius + 5)/(otherDist + 10)
	end
	
	if collideIntensity < 0.01 then
		collideIntensity = 0.01
	end
	
	collideMult = collideMult*dt
	self.AddSlowTime(dt*2)
	
	if other.AddPosition then
		self.AddPosition(util.Mult(-collideIntensity * collideMult, toOther))
		other.AddPosition(util.Mult(collideIntensity * collideMult, toOther))
		if other.AddSlowTime then
			other.AddSlowTime(dt*2)
		end
	elseif self.goal then
		local unitCollision = util.Unit(toOther)
		
		local goLeft = util.Cross2D(toOther, self.goal) < 0
		
		self.AddPosition(util.Mult(-collideIntensity * collideMult, toOther))
		local perpCollision
		if goLeft then
			perpCollision = util.RotateVector(unitCollision, -0.65*math.pi)
		else
			perpCollision = util.RotateVector(unitCollision, 0.65*math.pi)
		end
		
		self.AddPosition(util.Mult(6 + collideIntensity * collideMult * 2, perpCollision))
	end
end

function creatureUtils.DoCollisions(self, def, Terrain, Enemies, player, dt)
	local collideTerrain = Terrain.GetTerrainCollision(self.pos, def.radius + 20, true, false, false, dt)
	if collideTerrain then
		Collision(self, def, collideTerrain, 50, dt)
	end
	
	local collideOther = Enemies.DetectCollision(self.pos, def.radius, self.index, false, false, dt)
	if collideOther then
		Collision(self, def, collideOther, 30, dt)
	end
end

function creatureUtils.MoveTowardsPlayer(self, def, Terrain, Enemies, player, stopRange, goalOffset, dt)
	if self.slowTime then
		self.slowTime = self.slowTime - dt
		if self.slowTime < 0 then
			self.slowTime = false
		end
	end
	
	local playerPos = player.GetPhysics()
	self.direction = util.Angle(util.Subtract(playerPos, self.pos))
	self.turretDirection = self.direction
	
	if player.IsDead() then
		playerPos = util.Add(playerPos, {0, 3000})
	end
	if goalOffset then
		playerPos = util.Add(playerPos, goalOffset)
	end
	if self.randomGoalOffset then
		playerPos = util.Add(self.randomGoalOffset, playerPos)
	end
	self.goal = playerPos
	
	local toPlayer = util.Subtract(playerPos, self.pos)
	if stopRange and util.AbsVal(toPlayer) < stopRange then
		return
	end
	
	local speed = (self.wantedSpeed or def.speed) * ((self.slowTime and (1 - self.slowTime*0.4)) or 1)
	self.AddPosition(util.SetLength(speed * 60 * dt, toPlayer))
end

function creatureUtils.SetLimitedTurnDrawDir(self, def, dt)
	self.drawDir = self.drawDir or self.direction
	
	self.velocity = util.Subtract(self.pos, self.oldPos)
	local dirDiff = util.AngleSubtractShortest(util.Angle(self.velocity), self.drawDir)
	local wantTurn = util.SignPreserveMax(dirDiff, def.maxTurnRate*4)
	
	self.drawDirMomentum = util.SignPreserveMax(((self.drawDirMomentum or 0)*0.95 + wantTurn*dt), def.maxTurnRate)
	self.drawDir = self.drawDir + self.drawDirMomentum*60*dt
end

return creatureUtils
