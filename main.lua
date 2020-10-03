
Font = require("include/font")
Resources = require("resourceHandler")

--------------------------------------------------
-- Draw
--------------------------------------------------

local animDt = 0
function love.draw()
	Resources.DrawAnim("test_anim", 100, 100, animDt)
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

function love.update(dt)
	animDt = Resources.UpdateAnim("test_anim", animDt, dt)
end

--------------------------------------------------
-- Loading
--------------------------------------------------

function love.load()
	local major, minor, revision, codename = love.getVersion()
	print(string.format("Version %d.%d.%d - %s", major, minor, revision, codename))

	math.randomseed(os.clock())
	Resources.LoadResources()
end
