
local IterableMap = require("include/IterableMap")

local externalFunc = {}
local sounds = IterableMap.New()

local volMult = {
    bulletfire = 0.34,
}

local soundFiles = {
	bulletfire = {"sounds/bulletfire.wav", "static"}
}

function addSource(name, id)
    local def = soundFiles[name]
	if def then
        return love.audio.newSource(def[1], def[2])
    end
end

function externalFunc.PlaySound(name, id, loop, fadeRate, delay)
	id = name .. (id or 1)
	local soundData = IterableMap.Get(sounds, id)
    if not soundData then
        soundData = {
            name = name,
            want = 1,
            have = 0,
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
    end
end

function externalFunc.StopSound(id, death)
    local soundData = IterableMap.Get(sounds, id)
    if not soundData then
        return
    end
    soundData.want = 0
    if death then
        soundData.source:stop()
    end
end

function externalFunc.Update(dt)
    for _, soundData in IterableMap.Iterator(sounds) do
        if soundData.delay then
            soundData.delay = soundData.delay - dt
            if soundData.delay < 0 then
                soundData.delay = false
                if soundData.want > 0 then
                    love.audio.play(soundData.source)
                    soundData.source:setVolume(soundData.have*volMult[soundData.name])
                end
            end
        else
            if soundData.want > soundData.have then
                soundData.have = soundData.have + (soundData.fadeRate or 10)*dt
                if soundData.have > soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have*volMult[soundData.name])
            end

            if soundData.want < soundData.have then
                soundData.have = soundData.have - (soundData.fadeRate or 10)*dt
                if soundData.have < soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have*volMult[soundData.name])
            end
        end
    end
end

function externalFunc.Initialize()
    for _, soundData in IterableMap.Iterator(sounds) do
        soundData.source:stop()
    end
    sounds = IterableMap.New()
end

return externalFunc
