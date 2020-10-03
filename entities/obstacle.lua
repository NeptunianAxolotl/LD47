
local function NewObstacle(self)
	-- pos
	-- imageName
	-- health
	-- radius
	
	function self.Draw()
		Resources.DrawImage(self.imageName, self.pos[1], self.pos[2])
	end
	
	return self
end

return NewObstacle
