
local util = require("include/util")

local self = {
	debugMode = false
}

--------------------------------------------------
-- Images
--------------------------------------------------

local function LoadImage(resData)
	local image = love.graphics.newImage(resData.file)
	local imageWidth, imageHeight = image:getWidth(), image:getHeight()
	
	local data = {
		image = image,
		xScale = resData.xScale or 1,
		yScale = resData.yScale or 1,
		imageWidth = imageWidth,
		imageHeight = imageHeight,
	}
	data.xOffset = (resData.xOffset or 0.5)*imageWidth
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	return data
end

local function LoadIsoImage(resData)
	local image = {}
	local imageWidth, imageHeight
	for i = 1, #resData.files do
		image[i] = love.graphics.newImage(resData.files[i])
		if not imageWidth then
			imageWidth, imageHeight = image[i]:getWidth(), image[i]:getHeight()
		end
	end
	
	local data = {
		image = image,
		xScale = resData.xScale or 1,
		yScale = resData.yScale or 1,
		firstDir = resData.firstDir or 0,
		directionCount = #resData.files,
		rotate = resData.rotate,
	}
	data.xOffset = (resData.xOffset or 0.5)*imageWidth
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	return data
end

local function LoadAnimation(resData)
	local data = LoadImage(resData)
	
	data.quads = {}
	data.duration = resData.duration
	
	local width = resData.width
	local imageWidth = data.image:getWidth()
	local imageHeight = data.image:getHeight()
	
	data.xOffset = (resData.xOffset or 0.5)*imageWidth
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	data.quadWidth = width
	data.quadHeight = imageHeight
	
	for x = 0, imageWidth - width, width do
		--print(x)
		data.quads[#data.quads + 1] = love.graphics.newQuad(x, 0, width, imageHeight, imageWidth, imageHeight)
	end
	
	data.frames = #data.quads
	
	return data
end

local function LoadIsoAnimation(resData)
	local dirAnim = {}
	for i = 1, #resData.files do
		dirAnim[i] = LoadAnimation({
			file = resData.files[i],
			width = resData.width,
			duration = resData.duration,
			xScale = resData.xScale,
			yScale = resData.yScale,
			xOffset = resData.xOffset,
			yOffset = resData.yOffset,
		})
	end
	
	local data = {
		dirAnim = dirAnim,
		duration = resData.duration,
		firstDir = resData.firstDir or 0,
		directionCount = #resData.files,
		rotate = resData.rotate,
	}
	
	return data
end

--------------------------------------------------
-- Sound
--------------------------------------------------

local function LoadSound(resData)

end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function LoadResource(name)
	local res = require("resources/" .. name)
	if res.form == "image" then
		self.images[name] = LoadImage(res)
	elseif res.form == "iso_image" then
		self.images[name] = LoadIsoImage(res)
	elseif res.form == "animation" then
		self.animations[name] = LoadAnimation(res)
	elseif res.form == "iso_animation" then
		self.animations[name] = LoadIsoAnimation(res)
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

function self.DrawImage(name, x, y, rotation)
	if not self.images[name] then
		print("Invalid DrawImage ", name)
		return
	end
	
	rotation = rotation or 0
	love.graphics.setColor(1, 1, 1, 1)
	
	local data = self.images[name]
	love.graphics.draw(data.image, x, y, rotation, data.xScale, data.yScale, data.xOffset, data.yOffset, 0, 0)
end

function self.DrawIsoImage(name, x, y, direction)
	if not self.images[name] then
		print("Invalid DrawIsoImage ", name)
		return
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	local data = self.images[name]
	local drawDir = util.DirectionToCardinal(direction, data.firstDir, data.directionCount)
	
	local rotation = 0
	if data.rotate then
		rotation = -util.AngleToCardinal(direction, drawDir, data.firstDir, data.directionCount)
	end
	
	love.graphics.draw(data.image[drawDir], x, y, rotation, data.xScale, data.yScale, data.xOffset, data.yOffset, 0, 0)
end

function self.UpdateAnim(name, progress, dt)
	if not self.animations[name] then
		print("Invalid UpdateAnimation ", name)
		return
	end
	return (progress + dt)%self.animations[name].duration
end

function self.DrawAnimInternal(data, x, y, progress, rotation)
	love.graphics.setColor(1, 1, 1, 1)
	
	local quadToDraw = math.floor((progress%data.duration) / data.duration * data.frames) + 1
	
	love.graphics.draw(data.image, data.quads[quadToDraw], x, y, rotation, data.xScale, data.yScale, data.xOffset, data.yOffset, 0, 0)
	
	if self.debugMode then
		love.graphics.rectangle("line", x, y, data.quadWidth*data.xScale, data.quadHeight*data.yScale, 0, 0)
	end
end

function self.DrawAnim(name, x, y, progress, rotation)
	if not self.animations[name] then
		print("Invalid DrawAnimation ", name)
		return
	end
	self.DrawAnimInternal(self.animations[name], x, y, progress, rotation)
end

function self.DrawIsoAnimation(name, x, y, progress, direction)
	if not self.animations[name] then
		print("Invalid DrawIsoAnimation ", name)
		return
	end
	
	love.graphics.setColor(1, 1, 1, 1)
	
	local data = self.animations[name]
	local drawDir = util.DirectionToCardinal(direction, data.firstDir, data.directionCount)
	
	local rotation = 0
	if data.rotate then
		rotation = -util.AngleToCardinal(direction, drawDir, data.firstDir, data.directionCount)
	end
	
	self.DrawAnimInternal(data.dirAnim[drawDir], x, y, progress, rotation)
end


--------------------------------------------------
-- Drawing Functions
--------------------------------------------------

return self
