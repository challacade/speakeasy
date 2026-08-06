-- speakeasy demo: drop this folder on the LÖVE executable to run it.

-- The demo runs from inside the library folder; in your own project this is require("speakeasy").
local speakeasy = require("init")

local sample = "Greetings, traveler.\nThe road ahead is long, and the night is longer still. Rest here, and I will share my wisdom."

local aligns = { "left", "center", "right" }

local demo = {
    speed = 24,
    scale = 2,
    baseSize = 11,
    baseWidth = 200,
    align = 1,
    muted = false,
}

-- A tiny generated blip so the onGlyph callback has something to show off.
local function makeBlip()
    local rate = 44100
    local samples = math.floor(rate * 0.03)
    local data = love.sound.newSoundData(samples, rate, 16, 1)

    for index = 0, samples - 1 do
        local envelope = 1 - (index / samples)
        local value = math.sin((index / rate) * 2 * math.pi * 660) * 0.22 * envelope
        data:setSample(index, value)
    end

    return love.audio.newSource(data, "static")
end

local function onGlyph(glyph)
    if demo.muted or glyph.space then return end
    demo.blip:stop()
    demo.blip:setPitch(0.92 + love.math.random() * 0.16)
    demo.blip:play()
end

-- Text stays crisp because the font is rebuilt at the new size, never stretched by a transform.
local function applyScale()
    demo.line:setFont(love.graphics.newFont(math.floor(demo.baseSize * demo.scale)))
    demo.line:setWidth(demo.baseWidth * demo.scale)
end

function love.load()
    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), { resizable = true })
    love.graphics.setBackgroundColor(0.09, 0.10, 0.14)
    love.graphics.setLineStyle("rough")

    demo.blip = makeBlip()
    demo.uiFont = love.graphics.newFont(13)

    demo.line = speakeasy.new(sample, {
        speed = demo.speed,
        color = { 0.12, 0.11, 0.15, 1 },
        onGlyph = onGlyph,
    })

    applyScale()
end

function love.update(dt)
    demo.line:update(dt)
end

function love.draw()
    local width, height = love.graphics.getDimensions()
    local padding = math.floor(7 * demo.scale)
    local textWidth, textHeight = demo.line:getSize()
    local boxWidth = textWidth + padding * 2
    local boxHeight = textHeight + padding * 2
    local boxX = math.floor((width - boxWidth) / 2)
    local boxY = math.floor((height - boxHeight) / 2 + 24)

    love.graphics.setColor(0.94, 0.93, 0.88, 1)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 4, 4)

    demo.line:draw(boxX + padding, boxY + padding)

    love.graphics.setFont(demo.uiFont)
    love.graphics.setColor(1, 1, 1, 0.75)
    love.graphics.print("space: skip / restart    up down: speed    left right: wrap width    , .: scale    tab: align    m: mute    escape: quit", 20, 16)

    love.graphics.setColor(1, 1, 1, 0.45)
    love.graphics.print(string.format(
        "speed %d glyphs/sec   wrap %d   scale %.1f   align %s   %d of %d glyphs   sound %s",
        demo.speed, demo.baseWidth, demo.scale, aligns[demo.align],
        demo.line:getVisible(), demo.line:getCount(), demo.muted and "off" or "on"
    ), 20, 36)

    love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        if demo.line:isComplete() then demo.line:restart() else demo.line:skip() end
    elseif key == "r" then
        demo.line:restart()
    elseif key == "m" then
        demo.muted = not demo.muted
    elseif key == "up" or key == "down" then
        demo.speed = math.max(2, demo.speed + (key == "up" and 4 or -4))
        demo.line:setSpeed(demo.speed)
    elseif key == "left" or key == "right" then
        demo.baseWidth = math.max(50, demo.baseWidth + (key == "right" and 10 or -10))
        demo.line:setWidth(demo.baseWidth * demo.scale)
    elseif key == "," or key == "." then
        demo.scale = math.min(4, math.max(1, demo.scale + (key == "." and 0.5 or -0.5)))
        applyScale()
    elseif key == "tab" then
        demo.align = demo.align % #aligns + 1
        demo.line:setAlign(aligns[demo.align])
    end
end
