
local Font = require("include/font")
local Resources = require("resourceHandler")
local SpellHandler = require("spellHandler")
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
	World.MouseReleased()
end

function love.keypressed(key, scancode, isRepeat)
	if key == 'r' then
		World.Initialize()
	end
	if key == 'escape' then
	
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	World.MousePressed()
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
	
	if dt > 1/50 then
		print(1/dt)
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
	love.window.maximize()

	if arg[#arg] == "-debug" then require("mobdebug").start() end
	local major, minor, revision, codename = love.getVersion()
	io.stdout:setvbuf('no')
	print(string.format("LÖVE %d.%d.%d - %s", major, minor, revision, codename))
	print(_VERSION)
	math.randomseed(os.time()+os.clock())
	Resources.LoadResources()
	World.Initialize()
end
