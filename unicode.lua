-- Minimal UTF-8 helpers. Pure Lua 5.1+, no dependency on the 5.3 utf8 library.

local unicode = {}

local byte = string.byte
local sub = string.sub

-- Byte length of the sequence that starts with this lead byte.
local function sequenceLength(lead)
    if not lead then return 1 end
    if lead < 0x80 then return 1 end
    if lead >= 0xF0 then return 4 end
    if lead >= 0xE0 then return 3 end
    if lead >= 0xC0 then return 2 end
    return 1 -- stray continuation byte, treated as its own character
end

-- Iterate characters: for char, byteIndex in unicode.chars(str) do ... end
function unicode.chars(str)
    str = str or ""
    local index = 1
    local length = #str

    return function()
        if index > length then return nil end

        local start = index
        index = index + sequenceLength(byte(str, index))
        if index > length + 1 then index = length + 1 end

        return sub(str, start, index - 1), start
    end
end

function unicode.split(str)
    local characters = {}
    for char in unicode.chars(str) do
        characters[#characters + 1] = char
    end
    return characters
end

function unicode.len(str)
    local count = 0
    for _ in unicode.chars(str) do
        count = count + 1
    end
    return count
end

-- Substring by character index, negative indices count from the end.
function unicode.sub(str, first, last)
    local characters = unicode.split(str)
    local total = #characters

    first = first or 1
    last = last or total
    if first < 0 then first = total + first + 1 end
    if last < 0 then last = total + last + 1 end
    if first < 1 then first = 1 end
    if last > total then last = total end
    if first > last then return "" end

    return table.concat(characters, "", first, last)
end

return unicode
