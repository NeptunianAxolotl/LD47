
local util = require("include/util")

local self = {
	cameraPos = {0, 0},
	cameraVelocity = {0, 0},
	cameraScale = 1,
}

local function UpdateCamera(dt, playerPos, playerVelocity, playerSpeed, smoothness)
	self.cameraVelocity = util.Average(self.cameraVelocity, playerVelocity, 2*(1 - smoothness))
	self.cameraPos = util.Add(util.Mult(dt*60, self.cameraVelocity), util.Average(self.cameraPos, playerPos, (1 - smoothness)))
	
	local wantedScale = math.min(1, math.max(0.4, 23.5/(20 + playerSpeed)))
	self.cameraScale = self.cameraScale*smoothness + wantedScale*(1 - smoothness)
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

return {
	UpdateCamera = UpdateCamera,
}
