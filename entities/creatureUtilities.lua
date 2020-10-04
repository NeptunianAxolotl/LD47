
local util = require("include/util")

local creatureUtils = {}

local function Collision(self, def, other, collideMult, dt)
	local otherPos, otherRadius = other.GetPhysics()
	local toOther = util.Subtract(otherPos, self.pos)
	local otherDist = util.AbsVal(toOther)
	local collideIntensity = ((otherRadius + def.radius) - otherDist + 30)*0.002
	
	collideMult = collideMult*dt
	self.AddSlowTime(dt*2)
	
	if other.AddPosition then
		self.AddPosition(util.Mult(-collideIntensity * collideMult, toOther))
		other.AddPosition(util.Mult(collideIntensity * collideMult, toOther))
		if other.AddSlowTime then
			other.AddSlowTime(dt*2)
		end
	else
		local unitFacing = util.PolarToCart(1, self.direction)
		local unitCollision = util.Unit(toOther)
		local hitAngle = util.Dot(unitCollision, unitFacing)
		
		self.AddPosition(util.Mult(-collideIntensity * collideMult, toOther))
		if hitAngle > 0.8 then
			local perpCollision = util.RotateVector(unitCollision, 0.5*math.pi)
			local turnDirection = util.Dot(perpCollision, unitFacing) > 0 and 1 or -1
			
			self.AddPosition(util.Mult(turnDirection * collideIntensity * hitAngle * collideMult * 2, perpCollision))
		end
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
	
	if goalOffset then
		playerPos = util.Add(playerPos, goalOffset)
	end
	if self.randomGoalOffset then
		playerPos = util.Add(self.randomGoalOffset, playerPos)
	end
	
	local toPlayer = util.Subtract(playerPos, self.pos)
	if stopRange and util.AbsVal(toPlayer) < stopRange then
		return
	end
	
	local speed = def.speed * ((self.slowTime and (1 - self.slowTime*0.4)) or 1)
	self.AddPosition(util.SetLength(speed * dt, toPlayer))
end

return creatureUtils
