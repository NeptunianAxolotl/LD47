
local IterableMap = require("include/IterableMap")

local api = {}
local sounds = IterableMap.New()

local volMult = {
}

local soundFiles = {
	fireball_shoot = {file = "sounds/fireball_shoot1.wav", volMult = 0.1},
	haste_shoot   = {file = "sounds/haste_shoot0.wav", volMult = 0.34},
	serpent_shoot = {file = "sounds/serpent_shoot2.wav", volMult = 0.34},
	shield_shoot = {file = "sounds/shield_shoot6.wav", volMult = 0.34},
	shotgun_shoot = {file = "sounds/shotgun_shoot0.wav", volMult = 0.7},
	fireball_explode = {file = "sounds/fireball_explode0.wav", volMult = 0.2},
	health_up = {file = "sounds/health1.wav", volMult = 0.34},
	health_down = {file = "sounds/health_down0.wav", volMult = 1.5},
	wisp_shoot = {file = "sounds/wisp_shoot2.wav", volMult = 0.15},
	seeker_travel = {file = "sounds/seeker_travel0.wav", volMult = 0.12},
	death = {file = "sounds/death.wav", volMult = 0.40},
    crocodial_a = {file = "sounds/crocodial_a.wav", volMult = 0.13},
    crocodial_b = {file = "sounds/crocodial_b.wav", volMult = 0.13},
    crocodial_c = {file = "sounds/crocodial_c.wav", volMult = 0.14},
    crocodial_d = {file = "sounds/crocodial_d.wav", volMult = 0.15},
}

function addSource(name, id)
    local def = soundFiles[name]
	if def then
        return love.audio.newSource(def.file, "static")
    end
end

function api.PlaySound(name, loop, id, fadeRate, delay, fadeIn)
	id = name .. (id or 1)
    fadeIn = fadeIn or fadeRate
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
            fadeIn = fadeIn,
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
                soundData.have = soundData.have + (soundData.fadeIn or 10)*dt
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
