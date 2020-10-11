local IterableMap = require("include/IterableMap")

local SoundHandler = require("soundHandler")

local api = {}

local font = love.graphics.newFont(70)

local tracks = {
    intro = {id = 'a', sound = 'crocodial_a', duration = 6.04, canLoop = false},
    normal = {id = 'b', sound = 'crocodial_b', duration = 12.170, canLoop = true},
    late = {id = 'c', sound = 'crocodial_c', duration = 12.170, canLoop = true},
    boss = {id = 'd', sound = 'crocodial_d', duration = 12.170, canLoop = true}
}

local fadeRate = 1

local currentTrack = nil
local queuedTracks = {}
local currentTrackRemaining = 0

function api.SwitchTrack(id)
    if id == 'none' then 
        queuedTracks = {false}
        return true
    end
    if not tracks[id] then
        return false
    end
    queuedTracks = {tracks[id]}
    return true
end

function api.QueueTrack(id)
    if id == 'none' then 
        queuedTracks[#queuedTracks+1] = {false}
        return true
    end
    if not tracks[id] then
        return false
    end
    queuedTracks[#queuedTracks+1] = tracks[id]
    return true
end

function api.StopCurrentTrack()
    currentTrackRemaining = 0
end

function api.Update(dt)
    if currentTrack then
        currentTrackRemaining = currentTrackRemaining - dt
        if currentTrackRemaining < 0 then
            if #queuedTracks > 0 then
                SoundHandler.StopSound(currentTrack.sound .. '_track' .. currentTrack.id, false)
                currentTrack = queuedTracks[1]
                for i = 1, #queuedTracks-1 do
                    queuedTracks[i] = queuedTracks[i+1]
                end
                queuedTracks[#queuedTracks] = nil
                if currentTrack then 
                    SoundHandler.PlaySound(currentTrack.sound, currentTrack.canLoop, '_track' .. currentTrack.id, fadeRate, fadeRate, 0)
                end
            else
                if not currentTrack.canLoop then
                    SoundHandler.StopSound(currentTrack.sound .. '_track' .. currentTrack.id, false)
                    currentTrack = false
                end
            end
            currentTrackRemaining = currentTrack and currentTrack.duration or 0
        end
    else
        if #queuedTracks > 0 then
            currentTrack = queuedTracks[1]
            for i = 1, #queuedTracks-1 do
                queuedTracks[i] = queuedTracks[i+1]
            end
            queuedTracks[#queuedTracks] = nil
            if currentTrack then
                SoundHandler.PlaySound(currentTrack.sound, currentTrack.canLoop, '_track' .. currentTrack.id, 100, fadeRate, 0)
            end
            currentTrackRemaining = currentTrack and currentTrack.duration or 0
        else
            currentTrackRemaining = 0
        end
    end
end

function api.Draw(x,y)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setFont(font)
    love.graphics.print(currentTrack and currentTrack.id or (currentTrack == false and '0' or '-'),x,y, 0, 1, 1)
    love.graphics.print(#queuedTracks > 0 and (queuedTracks[1] == false and '0' or queuedTracks[1].id) or '-',x,y + 100, 0, 1, 1)
end

function api.Initialize()
    api.SwitchTrack('none')
    api.StopCurrentTrack()
end

return api