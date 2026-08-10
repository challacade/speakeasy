-- Lightweight glyph entrance interpolation. Pure math, no Love2D dependency.

local tween = {}

tween.defaults = {
    duration = 0.09,
    rise = 10,
    grow = 0.5,
    fade = 0,
}

local function smoothstep(progress)
    return progress * progress * (3 - 2 * progress)
end

function tween.resolve(options)
    if options == false then return false end
    options = options or {}

    return {
        duration = math.max(0, tonumber(options.duration) or tween.defaults.duration),
        rise = options.rise == false and 0 or tonumber(options.rise) or tween.defaults.rise,
        grow = options.grow == false and 1 or tonumber(options.grow) or tween.defaults.grow,
        fade = options.fade == false and 1 or tonumber(options.fade) or tween.defaults.fade,
        ease = options.ease or smoothstep,
    }
end

function tween.sample(age, options)
    if not options then return 0, 1, 1 end

    local progress = options.duration <= 0 and 1
        or math.min(1, math.max(0, (age or 0) / options.duration))
    local eased = options.ease(progress)
    local offsetY = options.rise * (1 - eased)
    local scale = options.grow + (1 - options.grow) * eased
    local alpha = options.fade + (1 - options.fade) * eased
    alpha = math.min(1, math.max(0, alpha))
    return offsetY, scale, alpha
end

return tween