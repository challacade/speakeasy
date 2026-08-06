-- Reveal timing. Pure state, no love dependency.

local reveal = {}

local Reveal = {}
Reveal.__index = Reveal
reveal.Reveal = Reveal

function reveal.new(options)
    options = options or {}

    return setmetatable({
        speed = options.speed or 30, -- glyphs per second, 0 or less reveals instantly
        onGlyph = options.onGlyph,
        count = 0,
        visible = 0,
        timer = 0,
        paused = false,
    }, Reveal)
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
    while self.timer >= interval and self.visible < self.count do
        self.timer = self.timer - interval
        self.visible = self.visible + 1
        if self.onGlyph then self.onGlyph(glyphs[self.visible], self.visible) end
    end

    if self:isComplete() then self.timer = 0 end
end

return reveal
