
local IterableMap = require("include/IterableMap")

local api = {}
local sounds = IterableMap.New()

local volMult = {
    bulletfire = 0.34,
}

local soundFiles = {
	bulletfire     = {file = "sounds/bulletfire.wav", volMult = 0.34},
	fireball_shoot = {file = "sounds/fireball_shoot1.wav", volMult = 0.34},
	haste_shoot   = {file = "sounds/haste_shoot0.wav", volMult = 0.34},
	serpent_shoot = {file = "sounds/serpent_shoot2.wav", volMult = 0.34},
	seeker_travel = {file = "sounds/seeker_travel0.wav", volMult = 0.10},
	beat1 = {file = "resources/sounds/beat1.wav", volMult = 0.15},
	beat2 = {file = "resources/sounds/beat2.wav", volMult = 0.15},
	beat3 = {file = "resources/sounds/beat3.wav", volMult = 0.15},
	beat4 = {file = "resources/sounds/beat4.wav", volMult = 0.15},
	beat5 = {file = "resources/sounds/beat5.wav", volMult = 0.15},
	beat6 = {file = "resources/sounds/beat6.wav", volMult = 0.15},
	beat7 = {file = "resources/sounds/beat7.wav", volMult = 0.15},
	beat8 = {file = "resources/sounds/beat8.wav", volMult = 0.15},
	beat8 = {file = "resources/sounds/beat8.wav", volMult = 0.15},
	fulltrack = {file = "resources/sounds/fulltrack.wav", volMult = 0.12},
}

function addSource(name, id)
    local def = soundFiles[name]
	if def then
        return love.audio.newSource(def.file, "static")
    end
end

function api.PlaySound(name, loop, id, fadeRate, delay)
	id = name .. (id or 1)
	local soundData = IterableMap.Get(sounds, id)
    if not soundData then
		local def = soundFiles[name]
        soundData = {
            name = name,
            want = 1,
            have = 0,
			volumeMult = def.volMult,
            source = addSource(name, id),
            fadeRate = fadeRate,
            delay = delay,
        }
		if loop then
			soundData.source:setLooping(true)
		end
        IterableMap.Add(sounds, id, soundData)
    end

    soundData.want = 1
    soundData.delay = delay
    if not soundData.delay then
        love.audio.play(soundData.source)
        soundData.source:setVolume(soundData.want * soundData.volumeMult)
    end
end

function api.StopSound(id, death)
    local soundData = IterableMap.Get(sounds, id)
    if not soundData then
        return
    end
    soundData.want = 0
    if death then
        soundData.source:stop()
    end
end

function api.Update(dt)
    for _, soundData in IterableMap.Iterator(sounds) do
        if soundData.delay then
            soundData.delay = soundData.delay - dt
            if soundData.delay < 0 then
                soundData.delay = false
                if soundData.want > 0 then
                    love.audio.play(soundData.source)
                    soundData.source:setVolume(soundData.have * soundData.volumeMult)
                end
            end
        else
            if soundData.want > soundData.have then
                soundData.have = soundData.have + (soundData.fadeRate or 10)*dt
                if soundData.have > soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have * soundData.volumeMult)
            end

            if soundData.want < soundData.have then
                soundData.have = soundData.have - (soundData.fadeRate or 10)*dt
                if soundData.have < soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have * soundData.volumeMult)
            end
        end
    end
end

function api.Initialize()
    for _, soundData in IterableMap.Iterator(sounds) do
        soundData.source:stop()
    end
    sounds = IterableMap.New()
	
	
end

return api
