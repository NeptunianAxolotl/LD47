
local util = require("include/util")

local self = {
	cameraPos = {0, 0},
	cameraVelocity = {0, 0},
	cameraScale = 1,
}

local function UpdateCamera(dt, playerPos, playerVelocity, playerSpeed)
	self.cameraVelocity = util.Average(self.cameraVelocity, playerVelocity, 0.4)
	self.cameraPos = util.Add(util.Mult(dt*60, self.cameraVelocity), util.Average(self.cameraPos, playerPos, 0.2))
	
	local wantedScale = math.min(1, math.max(0.45, 25/(20 + playerSpeed)))
	self.cameraScale = self.cameraScale*0.8 + wantedScale*0.2
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

return {
	UpdateCamera = UpdateCamera,
}
