
local util = require("include/util")
local Resources = require("resourceHandler")

local function NewSpell(player)
	local self = {}
	
	self.pos, self.velocity = player.GetPhysics()
	self.velocity = util.Norm(25, self.velocity)
	
	function self.Update(dt)
		self.pos = util.Add(util.Mult(dt*60, self.velocity), self.pos)
	end
	
	function self.Draw()
		Resources.DrawIsoImage("fireball", self.pos[1], self.pos[2], util.Angle(self.velocity))
	end
	
	return self
end

return NewSpell
