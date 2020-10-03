
local self = {}

function self.Update(playerX, playerY, dt)
	-- Creates and removes mechanical obstacles as well as graphical things based on
	-- player position. Things may use dt to animate or otherwise do stuff (like a tree burning down).
	
	-- Include and deal with individual behaviours for dynamic feature (a burning tree, an exploding bomb etc..) here.
end

function self.GetTerrainCollision(x, y, radius)
	-- Other things, such as the player, enemies, and active spell effects, may call the terrain
	-- to check whether they are colliding with any mechanical part of it.
end

return self