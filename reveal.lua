-- Reveal timing. Pure state, no love dependency.

local reveal = {}

local Reveal = {}
Reveal.__index = Reveal
reveal.Reveal = Reveal

reveal.defaultPauseFactors = {
    sentence = 5,
    clause = 2,
}

reveal.defaultPunctuationPauses = {
    ["."] = "sentence",
    ["!"] = "sentence",
    ["?"] = "sentence",
    ["…"] = "sentence",
    [","] = "clause",
    [";"] = "clause",
    [":"] = "clause",
}

function reveal.new(options)
    options = options or {}
    local punctuationPauses = options.punctuationPauses
    if punctuationPauses == false then punctuationPauses = nil end
    if punctuationPauses == nil and options.punctuationPauses ~= false then
        punctuationPauses = reveal.defaultPunctuationPauses
    end
    local pauseFactors = options.pauseFactors or reveal.defaultPauseFactors

    return setmetatable({
        speed = options.speed or 30, -- glyphs per second, 0 or less reveals instantly
        onGlyph = options.onGlyph,
        punctuationPauses = punctuationPauses,
        pauseFactors = pauseFactors,
        count = 0,
        visible = 0,
        timer = 0,
        paused = false,
    }, Reveal)
end

function Reveal:getPunctuationPause(glyph, interval)
    local pauses = self.punctuationPauses
    if not pauses or not glyph then return 0 end
    local factor = pauses[glyph.char]
    if type(factor) == "string" then factor = self.pauseFactors[factor] end
    return (tonumber(factor) or 0) * interval
end

function Reveal:setCount(count)
    self.count = count or 0
    if self.visible > self.count then self.visible = self.count end
end

function Reveal:reset()
    self.visible = 0
    self.timer = 0
end

function Reveal:skip()
    self.visible = self.count
    self.timer = 0
end

function Reveal:isComplete()
    return self.visible >= self.count
end

function Reveal:update(dt, glyphs)
    if self.paused or self:isComplete() then return end

    local interval = self.speed > 0 and (1 / self.speed) or 0
    if interval <= 0 then
        self.timer = 0
        while self.visible < self.count do
            self.visible = self.visible + 1
            if self.onGlyph then self.onGlyph(glyphs[self.visible], self.visible) end
        end
        return
    end

    self.timer = self.timer + (dt or 0)
    while self.visible < self.count do
        local previousGlyph = self.visible > 0 and glyphs[self.visible] or nil
        local nextInterval = interval + self:getPunctuationPause(previousGlyph, interval)
        if self.timer < nextInterval then break end

        self.timer = self.timer - nextInterval
        self.visible = self.visible + 1
        if self.onGlyph then self.onGlyph(glyphs[self.visible], self.visible) end
    end

    if self:isComplete() then self.timer = 0 end
end

return reveal
