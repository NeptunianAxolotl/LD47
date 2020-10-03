
local util = require("include/util")

local self = {
	cameraPos = {0, 0},
	cameraVelocity = {0, 0},
	cameraScale = 1,
}

local function UpdateCamera(dt, playerPos, playerVelocity, playerSpeed)
	self.cameraVelocity = util.Average(self.cameraVelocity, playerVelocity, 0.2)
	self.cameraPos = util.Add(self.cameraVelocity, util.Average(self.cameraPos, playerPos, 0.2))
	
	local wantedScale = math.min(1, 25/(20 + playerSpeed))
	self.cameraScale = (self.cameraScale + wantedScale)/2
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

return {
	UpdateCamera = UpdateCamera,
}
