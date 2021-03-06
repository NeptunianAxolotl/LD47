
local Resources = require("resourceHandler")
local Progression = require("progression")

local backgrounds = {
	{
		name = "background_1",
		size = 2800,
		alpha = 1,
		xOffset = math.random()*2800,
		yOffset = math.random()*2800,
	},
	{
		name = "background_2",
		size = 4500,
		alpha = 0.7,
		xOffset = math.random()*4500,
		yOffset = math.random()*4500,
	},
}

local function DrawBackground(def, left, top, right, bottom)
	local floorLeft = math.floor((left - def.xOffset) / def.size)*def.size + def.xOffset
	local floorTop  = math.floor((top  - def.yOffset) / def.size)*def.size + def.yOffset
	
	local color = Progression.GetBackgroundColor(top)

	for x = floorLeft, right, def.size do
		for y = floorTop, bottom, def.size do
			Resources.DrawImage(def.name, x, y, false, def.alpha, false, color)
		end
	end
end

function DrawOverlappingBackground()
	local left, top = love.graphics.inverseTransformPoint(0,0)
	local right, bottom = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
	for i = 1, #backgrounds do
		DrawBackground(backgrounds[i], left, top, right, bottom)
	end
end

return DrawOverlappingBackground
