-- The only module that touches love.graphics.
-- Everything is drawn in font units at the given origin; the caller owns any camera or scale transform.

local draw = {}

local function setColor(value)
    love.graphics.setColor(value[1] or 1, value[2] or 1, value[3] or 1, value[4] or 1)
end

function draw.glyphs(result, visible, x, y, options)
    if not result or visible <= 0 then return end
    options = options or {}

    local glyphs = result.glyphs
    local previousFont = love.graphics.getFont()
    local red, green, blue, alpha = love.graphics.getColor()

    if options.font then love.graphics.setFont(options.font) end

    local shadow = options.shadow
    if shadow then
        local offsetX = shadow.offsetX or shadow.offset or 1
        local offsetY = shadow.offsetY or shadow.offset or 1
        setColor(shadow.color or { 0, 0, 0, 0.6 })
        for index = 1, visible do
            local glyph = glyphs[index]
            love.graphics.print(glyph.char, math.floor(x + glyph.x + offsetX), math.floor(y + glyph.y + offsetY))
        end
    end

    setColor(options.color or { red, green, blue, alpha })
    for index = 1, visible do
        local glyph = glyphs[index]
        love.graphics.print(glyph.char, math.floor(x + glyph.x), math.floor(y + glyph.y))
    end

    love.graphics.setColor(red, green, blue, alpha)
    if options.font and previousFont then love.graphics.setFont(previousFont) end
end

return draw
