local path = (...):gsub("%.init$", "")
local prefix = path == "init" and "" or (path .. ".")

local layout = require(prefix .. "layout")
local reveal = require(prefix .. "reveal")
local painter = require(prefix .. "draw")
local unicode = require(prefix .. "unicode")

local speakeasy = {
    _LICENSE = "This software is distributed under the MIT license. View the LICENSE on GitHub for details.",
    _URL = "https://github.com/challacade/speakeasy",
    _VERSION = "1.0.0",
    _DESCRIPTION = "Character-by-character text reveal for Love2D",
}

speakeasy.unicode = unicode
speakeasy.layout = layout
speakeasy.reveal = reveal
speakeasy.draw = painter

local Text = {}
Text.__index = Text
speakeasy.Text = Text

-- speakeasy.new(source, options)
-- options: font, width (wrap limit), speed, align, lineHeight, color, shadow,
-- onGlyph, punctuationPauses (glyph -> pause level/factor, or false to disable),
-- pauseFactors (pause level -> interval factor)
function speakeasy.new(source, options)
    options = options or {}

    local self = setmetatable({}, Text)

    self.font = options.font or (love and love.graphics and love.graphics.getFont())
    assert(self.font and self.font.getWidth, "speakeasy requires a font with getWidth/getHeight")

    self.width = options.width
    self.align = options.align or "left"
    self.lineHeight = options.lineHeight or self.font:getHeight()
    self.color = options.color
    self.shadow = options.shadow
    self.onGlyph = options.onGlyph

    self.reveal = reveal.new({
        speed = options.speed,
        punctuationPauses = options.punctuationPauses,
        pauseFactors = options.pauseFactors,
        onGlyph = function(glyph, index)
            if self.onGlyph then self.onGlyph(glyph, index, self) end
        end,
    })

    self:setText(source)

    return self
end

function Text:refresh()
    local font = self.font
    self.result = layout.build(self.source, {
        measure = function(char) return font:getWidth(char) end,
        lineHeight = self.lineHeight,
        width = self.width,
        align = self.align,
    })
    self.reveal:setCount(self.result.count)
    return self
end

function Text:setText(source)
    self.source = source or ""
    self:refresh()
    self.reveal:reset()
    return self
end

function Text:setFont(font, lineHeight)
    assert(font and font.getWidth, "setFont requires a font with getWidth/getHeight")
    self.font = font
    self.lineHeight = lineHeight or font:getHeight()
    return self:refresh()
end

function Text:setWidth(width)
    self.width = width
    return self:refresh()
end

function Text:setAlign(align)
    self.align = align or "left"
    return self:refresh()
end

function Text:setLineHeight(lineHeight)
    self.lineHeight = lineHeight or self.font:getHeight()
    return self:refresh()
end

function Text:setSpeed(speed)
    self.reveal.speed = speed or 0
    return self
end

function Text:getSpeed()
    return self.reveal.speed
end

function Text:update(dt)
    self.reveal:update(dt, self.result.glyphs)
    return self
end

function Text:draw(x, y, options)
    options = options or {}
    painter.glyphs(self.result, self.reveal.visible, x or 0, y or 0, {
        font = self.font,
        color = options.color or self.color,
        shadow = options.shadow or self.shadow,
    })
    return self
end

function Text:skip()
    self.reveal:skip()
    return self
end

function Text:restart()
    self.reveal:reset()
    return self
end

function Text:pause(value)
    self.reveal.paused = value ~= false
    return self
end

function Text:isPaused()
    return self.reveal.paused
end

function Text:isComplete()
    return self.reveal:isComplete()
end

function Text:getProgress()
    if self.result.count == 0 then return 1 end
    return self.reveal.visible / self.result.count
end

function Text:getVisible()
    return self.reveal.visible
end

function Text:getCount()
    return self.result.count
end

function Text:getWidth()
    return self.result.width
end

function Text:getHeight()
    return self.result.height
end

function Text:getSize()
    return self.result.width, self.result.height
end

function Text:getLineCount()
    return #self.result.lines
end

function Text:getText()
    return self.source
end

return speakeasy
