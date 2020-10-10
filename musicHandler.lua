

local IterableMap = require("include/IterableMap")

local SoundHandler = require("soundHandler")

local api = {}

local font = love.graphics.newFont(70)

local tracks = {
    intro = {debugid = 'a', sound = 'crocodial_a', duration = 6.05, canLoop = false},
    normal = {debugid = 'b', sound = 'crocodial_b', duration = 12.170, canLoop = true},
    late = {debugid = 'c', sound = 'crocodial_c', duration = 12.170, canLoop = true},
    boss = {debugid = 'd', sound = 'crocodial_d', duration = 12.170, canLoop = true}
}

local fadeRate = 1

local currentTrack = nil
local currentFade = nil
local queuedTracks = {}
local currentTrackRemaining = 0

function api.SwitchTrack(id)
    if not tracks[id] then
        return false
    end
    queuedTracks = {tracks[id]}
end

function api.QueueTrack(id)
    if not tracks[id] then
        return false
    end
    queuedTracks[#queuedTracks+1] = tracks[id]
end

function api.Update(dt)
    if currentTrack then
        currentTrackRemaining = currentTrackRemaining - dt
        if currentTrackRemaining < 0 then
            if #queuedTracks > 0 then
                SoundHandler.StopSound(currentTrack.sound, false)
                currentTrack = queuedTracks[1]
                SoundHandler.PlaySound(currentTrack.sound, currentTrack.canLoop, '', currentFade, fadeRate, 0)
                currentFade = fadeRate
                for i = 1, #queuedTracks-1 do
                    queuedTracks[i] = queuedTracks[i+1]
                end
                queuedTracks[#queuedTracks] = nil
            end
            currentTrackRemaining = currentTrack.duration
        end
    else
        if #queuedTracks > 0 then
            currentTrack = queuedTracks[1]
            currentFade = 100
            SoundHandler.PlaySound(currentTrack.sound, currentTrack.canLoop, '', 100, fadeRate, 0)
            for i = 1, #queuedTracks-1 do
                queuedTracks[i] = queuedTracks[i+1]
            end
            queuedTracks[#queuedTracks] = nil
            currentTrackRemaining = currentTrack.duration
        end
    end
end

-- function api.Draw(x,y)
    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.setFont(font)
    -- love.graphics.print(currentTrack and currentTrack.debugid or '0',x,y, 0, 1, 1)
    -- love.graphics.print(#queuedTracks > 0 and queuedTracks[1].debugid or '0',x,y + 100, 0, 1, 1)
-- end

function api.Initialize()
    local currentTrack = nil
    local currentFade = nil
    local queuedTracks = {}
    local currentTrackRemaining = 0
end

return api