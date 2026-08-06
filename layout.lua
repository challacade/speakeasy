-- Word wrapping into a fixed glyph layout.
-- The whole string is wrapped once so revealed text never reflows as it appears.

local prefix = (...):match("^(.*%.)[^%.]+$") or ""
local unicode = require(prefix .. "unicode")

local layout = {}

-- Builds { glyphs, lines, count, width, height, lineHeight } from a plain string.
-- options: measure(char) -> width, lineHeight, width (wrap limit), align
function layout.build(source, options)
    options = options or {}

    local measure = options.measure
    local lineHeight = options.lineHeight or 0
    local limit = options.width
    local align = options.align or "left"

    local glyphs = {}
    local lines = {}
    local line
    local lineWidth = 0

    local function startLine()
        line = { glyphs = {}, width = 0 }
        lines[#lines + 1] = line
        lineWidth = 0
    end

    local function breakLine()
        line.width = lineWidth
        startLine()
    end

    local function place(glyph)
        -- Only triggers mid-word when a single word is wider than the limit.
        if limit and lineWidth > 0 and lineWidth + glyph.width > limit then
            breakLine()
        end

        glyph.x = lineWidth
        glyph.line = #lines
        lineWidth = lineWidth + glyph.width

        line.glyphs[#line.glyphs + 1] = glyph
        glyphs[#glyphs + 1] = glyph
        glyph.index = #glyphs
    end

    local word, wordWidth = {}, 0
    local spaces, spacesWidth = {}, 0

    local function flushWord()
        if #word == 0 then return end

        if limit and lineWidth > 0 and lineWidth + spacesWidth + wordWidth > limit then
            breakLine() -- the spaces are dropped rather than dangling at the wrap
        else
            for index = 1, #spaces do place(spaces[index]) end
        end

        for index = 1, #word do place(word[index]) end

        word, wordWidth = {}, 0
        spaces, spacesWidth = {}, 0
    end

    startLine()

    for char in unicode.chars(source) do
        if char == "\n" then
            flushWord()
            spaces, spacesWidth = {}, 0
            breakLine()
        elseif char == " " or char == "\t" then
            flushWord()
            local glyph = { char = char, width = measure(char), space = true }
            spaces[#spaces + 1] = glyph
            spacesWidth = spacesWidth + glyph.width
        else
            local glyph = { char = char, width = measure(char) }
            word[#word + 1] = glyph
            wordWidth = wordWidth + glyph.width
        end
    end

    flushWord()
    line.width = lineWidth

    local maxWidth = 0
    for index = 1, #lines do
        if lines[index].width > maxWidth then maxWidth = lines[index].width end
    end

    -- Aligning against the measured block keeps getWidth() consistent with glyph positions.
    local reference = maxWidth
    for index = 1, #lines do
        local entry = lines[index]
        entry.y = (index - 1) * lineHeight

        local offset = 0
        if align == "center" then
            offset = (reference - entry.width) / 2
        elseif align == "right" then
            offset = reference - entry.width
        end
        entry.offset = offset

        for _, glyph in ipairs(entry.glyphs) do
            glyph.x = glyph.x + offset
            glyph.y = entry.y
        end
    end

    return {
        glyphs = glyphs,
        lines = lines,
        count = #glyphs,
        width = maxWidth,
        height = #lines * lineHeight,
        lineHeight = lineHeight,
    }
end

return layout
