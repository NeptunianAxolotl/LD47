
local Resources = require("resourceHandler")

local backgrounds = {
	{
		name = "background_1",
		size = 2800,
	},
	{
		name = "background_2",
		size = 4500,
	},
}

local function DrawBackground(name, size, left, top, right, bottom)
	local floorLeft, floorTop = math.floor(left/size)*size, math.floor(top/size)*size
	
	for x = floorLeft, right, size do
		for y = floorTop, bottom, size do
			Resources.DrawImage(name, x, y)
		end
	end
end

function DrawOverlappingBackground()
	local left, top = love.graphics.inverseTransformPoint(0,0)
	local right, bottom = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
	for i = 1, #backgrounds do
		DrawBackground(backgrounds[i].name, backgrounds[i].size, left, top, right, bottom)
	end
end

return DrawOverlappingBackground
