
local util = require("include/util")

local self = {
	cameraPos = {0, 0},
	cameraVelocity = {0, 0},
}

local function UpdateCamera(dt, playerPos, playerVelocity)
	local windowX, windowY = love.window.getMode()
	
	local centrePos = util.Subtract(playerPos, {windowX/2, 120})
	
	self.cameraVelocity = util.Average(self.cameraVelocity, playerVelocity, 0.2)
	self.cameraPos = util.Add(self.cameraVelocity, util.Average(self.cameraPos, centrePos, 0.2))
	
	return self.cameraPos[1], self.cameraPos[2]
end

return {
	UpdateCamera = UpdateCamera,
}
