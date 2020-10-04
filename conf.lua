function love.conf(t)
	t.window.title = "LD47"
	t.window.width = 1280
	t.window.height = 768
	--t.window.fullscreen = true -- Do not fullscreen since we lack an exit button.
	t.window.resizable = true
	--t.window.icon = "Images/icon.png"

	t.modules.joystick = false
    --t.window.fullscreen = true 
    t.window.fullscreentype = "desktop" 
end

