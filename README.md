# speakeasy

Character-by-character text reveal for Love2D

speakeasy reveals text one character at a time. It wraps the whole string once into a fixed glyph layout, so revealed text never reflows as it appears, and it stays out of your way about fonts, cameras, and scaling.

```lua
local speakeasy = require("speakeasy")

local line = speakeasy.new("Hello, traveler.", {
    font  = myFont,
    width = 160,  -- wrap limit, in the same units as the font
    speed = 24,   -- glyphs per second
})
```
```lua
-- put in the update loop
line:update(dt)

-- put in the draw method
line:draw(x, y)
```

## Scaling

speakeasy has no concept of scale. Everything is measured through the font you hand it and drawn at the origin you pass to `draw`, so the same instance works inside a camera transform, inside a virtual-resolution transform, or in raw screen space.

For crisp text at different sizes, build the font at the size you actually want and call `line:setFont(font)` rather than stretching a small font with a transform. Wrap widths are in font units, so scale them alongside the font.

## Options

Pass these as the second argument to `speakeasy.new(text, options)`:

- `font`: any object with `getWidth(text)` and `getHeight()`. LÖVE fonts qualify, and so does a bitmap-font wrapper of your own. Defaults to the current LÖVE font.
- `width`: wrap limit in font units. Omit it for no wrapping; `\n` always breaks a line.
- `speed`: glyphs per second. `0` or less reveals instantly.
- `align`: `"left"`, `"center"`, or `"right"`, aligned against the measured block width.
- `lineHeight`: pixels between lines. Defaults to `font:getHeight()`.
- `color`: `{r, g, b, a}` used when drawing. Defaults to the current LÖVE color.
- `shadow`: `{offset = 1, offsetX = 1, offsetY = 1, color = {0, 0, 0, 0.6}}`, or omit for none.
- `onGlyph`: `function(glyph, index, line)` called once per revealed character. Use it for typing sounds. Space characters have `glyph.space == true`.

## API

| Method | Purpose |
| --- | --- |
| `line:update(dt)` | Advance the reveal |
| `line:draw(x, y, options)` | Draw revealed characters; `options` can override `color` and `shadow` |
| `line:skip()` | Reveal everything immediately |
| `line:restart()` | Hide everything and start over |
| `line:pause(value)` | Freeze or resume the reveal |
| `line:isComplete()` | Whether every character is visible |
| `line:getProgress()` | Reveal progress from `0` to `1` |
| `line:getSize()` | Measured width and height of the wrapped block, for sizing a bubble around it |
| `line:getWidth()`, `line:getHeight()`, `line:getLineCount()` | Individual layout metrics |
| `line:getVisible()`, `line:getCount()` | Revealed and total character counts |
| `line:setText(text)` | Replace the text and restart |
| `line:setFont(font, lineHeight)`, `line:setWidth(w)`, `line:setAlign(a)`, `line:setLineHeight(h)` | Re-layout in place |
| `line:setSpeed(speed)`, `line:getSpeed()` | Reveal rate |

Everything measures and positions per character, using the font's advance width for each one. `speakeasy.unicode` exposes the multibyte-safe `len`, `sub`, `split`, and `chars` helpers the library uses internally, so accented and Private Use Area glyphs reveal correctly.

## Layout details

Text is laid out relative to `(0, 0)`, then drawn at the origin you pass in. Word wrapping breaks on spaces; a single word wider than the limit is broken between characters. A space that falls on a wrap point is dropped rather than left dangling, so it costs no reveal time.

## Structure

Drop this folder into your project as `speakeasy` and `require("speakeasy")` finds `init.lua`. The core (`unicode.lua`, `layout.lua`, `reveal.lua`) is plain Lua with no LÖVE dependency; only `draw.lua` touches `love.graphics`.

You can also run this repo as a LÖVE game to see the demo in `main.lua`. Because the demo lives beside the library rather than above it, it uses `require("init")` where your project would use `require("speakeasy")`.
