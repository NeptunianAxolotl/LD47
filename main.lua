
local Font = require("include/font")
local Resources = require("resourceHandler")
local World = require("world")

--------------------------------------------------
-- Draw
--------------------------------------------------

function love.draw()
	--Resources.DrawAnim("test_anim", 100, 100, animDt)
	World.Draw()
end

--------------------------------------------------
-- Input
--------------------------------------------------

function love.mousemoved(x, y, dx, dy, istouch )
end

function love.mousereleased(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
end

--------------------------------------------------
-- Update
--------------------------------------------------

local acc = 0
function love.update(dt)
	--animDt = Resources.UpdateAnim("test_anim", animDt, dt/5)
	if dt > 0.08 then
		dt = 0.08
	end
	acc = acc + dt
	if acc < 1/4000 then
		return
	end
	World.Update(acc)
	acc = 0
end

--------------------------------------------------
-- Loading
--------------------------------------------------
function love.load(arg)
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	local major, minor, revision, codename = love.getVersion()
	io.stdout:setvbuf('no')
	print(string.format("LÖVE %d.%d.%d - %s", major, minor, revision, codename))
	print(_VERSION)
	math.randomseed(os.time()+os.clock())
	Resources.LoadResources()
	World.Initialize()
end
