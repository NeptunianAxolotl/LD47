
local shapes = {}

for i = 3, 8 do
	shapes[#shapes + 1] = {
		form = "image",
		name = "shape_" .. i,
		file = "resources/images/shape_" .. i .. ".png",
		xScale = 0.9,
		yScale = 0.9,
		yOffset = 0.64
	}
end

return shapes
