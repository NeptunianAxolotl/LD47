
local util = require("include/util")

local creatureUtils = {}

function creatureUtils.DoCollisions(self, def, Terrain, Enemies, player, dt)
	local nearbyCollide = Terrain.GetTerrainCollision(self.pos, def.radius + 20, true, false, false, dt)
	local collideMult = ((nearbyCollide and 50) or 20)*dt
	nearbyCollide = nearbyCollide or Enemies.DetectCollision(self.pos, def.radius, self.index, false, false, dt)

	if nearbyCollide then
		local otherPos, otherRadius = nearbyCollide.GetPhysics()
		local toOther = util.Subtract(otherPos, self.pos)
		local otherDist = util.AbsVal(toOther)
		local collideIntensity = ((otherRadius + def.radius) - otherDist + 30)*0.002
		
		if nearbyCollide.AddPosition then
			self.AddPosition(util.Mult(-collideIntensity * collideMult, toOther))
			nearbyCollide.AddPosition(util.Mult(collideIntensity * collideMult, toOther))
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
end

function creatureUtils.MoveTowardsPlayer(self, def, Terrain, Enemies, player, dt)
	local playerPos = player.GetPhysics()
	self.direction = util.Angle(util.Subtract(playerPos, self.pos))
	
	self.AddPosition(util.PolarToCart(def.speed * dt, self.direction))
end

return creatureUtils
