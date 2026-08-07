-- Procedurally synthesized sound effects. No audio assets: every sound is a
-- short square-wave tone with a pitch envelope, generated at runtime into a
-- SoundData buffer.
local sfx = {}

local function buildSource(f1, f2, dur, vol)
    if not love.sound then return nil end
    local ok, src = pcall(function()
        local rate = love.sound.getSampleRate() or 44100
        local n = math.max(1, math.floor(rate * dur))
        local data = love.sound.newSoundData(n, rate, 16, 1)
        local phase = 0
        for i = 0, n - 1 do
            local t = i / rate
            local ph = t / dur
            local freq = f1 + (f2 - f1) * ph
            phase = phase + freq / rate
            local s = math.sin(2 * math.pi * phase)
            local env = (1 - ph) ^ 2
            data:setSample(i, s * vol * env)
        end
        local s = love.audio.newSource(data, 'static')
        s:setVolume(0.4)
        return s
    end)
    if ok then return src end
    return nil
end

local function play(src)
    if src then
        pcall(function() src:play() end)
    end
end

function sfx.shoot()
    play(buildSource(680 + love.math.random(0, 60), 220, 0.11, 0.5))
end

function sfx.enemyshoot()
    play(buildSource(320, 140, 0.14, 0.4))
end

function sfx.hit()
    play(buildSource(340, 90, 0.16, 0.6))
end

function sfx.hurt()
    play(buildSource(220, 70, 0.22, 0.55))
end

function sfx.pickup()
    play(buildSource(540, 880, 0.12, 0.4))
end

function sfx.key()
    play(buildSource(520, 820, 0.14, 0.5))
    play(buildSource(820, 1180, 0.14, 0.5))
end

function sfx.level()
    play(buildSource(400, 900, 0.28, 0.5))
end

return sfx
