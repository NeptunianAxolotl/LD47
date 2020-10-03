
local Player = require("player")
local Terrain = require("terrainHandler")

local self = {}

function self.Update(dt)
	Terrain.Update(0, 0, dt)
end

function self.Draw()
	Terrain.Draw(0, 0)
	Player.Draw()
end

function self.Initialize()
	Player.Initialize()
end

return self