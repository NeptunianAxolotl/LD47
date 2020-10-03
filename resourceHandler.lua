
local self = {
	debugMode = false
}

--------------------------------------------------
-- Loading Functions
--------------------------------------------------

local function LoadImage(resData)
	local image = love.graphics.newImage(resData.file)
	return {
		image = image,
		xScale = resData.xScale or 1,
		yScale = resData.yScale or 1,
	}
end

local function LoadAnimation(resData)
	local v = LoadImage(resData)
	
	v.quads = {}
	v.duration = resData.duration
	
	v.xoffset = resData.xoffset or 0
	v.yoffset = resData.yoffset or 0
	
	local width = resData.width
	local imageWidth = v.image:getWidth()
	local imageHeight = v.image:getHeight()
	
	v.quadWidth = width
	v.quadHeight = imageHeight
	
	for x = 0, imageWidth - width, width do
		--print(x)
		v.quads[#v.quads + 1] = love.graphics.newQuad(x, 0, width, imageHeight, imageWidth, imageHeight)
	end
	
	v.frames = #v.quads
	
	return v
end

local function LoadSound(resData)

end

local function LoadResource(name)
	local res = require("resources/" .. name)
	if res.form == "image" then
		self.images[name] = LoadImage(res)
	elseif res.form == "animation" then
		self.animations[name] = LoadAnimation(res)
	elseif res.form == "sound" then
		self.sounds[name] = LoadSound(res)
	else
		print("Invalid form ", res.form, " for resource ", name)
	end
end

function self.LoadResources()
	local resList = require("resources/resourceList")
	self.images = {}
	self.animations = {}
	self.sounds = {}
	
	for i = 1, #resList do
		LoadResource(resList[i])
	end
end

--------------------------------------------------
-- Drawing Functions
--------------------------------------------------

function self.UpdateAnim(name, progress, dt)
	if not self.animations[name] then
		print("Invalid UpdateAnimation ", name)
		return
	end
	return (progress + dt)%self.animations[name].duration
end

function self.DrawAnim(name, x, y, progress)
	if not self.animations[name] then
		print("Invalid DrawAnimation ", name)
		return
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	local anim = self.animations[name]
	local quadToDraw = math.floor((progress%anim.duration) / anim.duration * anim.frames) + 1
	love.graphics.draw(anim.image, anim.quads[quadToDraw], x + anim.xoffset, y + anim.yoffset, 0, anim.xScale, anim.yScale, 0, 0, 0, 0)
	
	if self.debugMode then
		love.graphics.rectangle("line", x, y, anim.quadWidth*anim.xScale, anim.quadHeight*anim.yScale, 0, 0)
	end
end

--------------------------------------------------
-- Drawing Functions
--------------------------------------------------

return self
