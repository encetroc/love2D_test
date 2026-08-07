-- Base for every shared object. Handles the common fields and applies the
-- optional construction table so callers can override defaults.
GameObject = Object:extend()

function GameObject:init(area, x, y, opts)
    self.area = area
    self.x, self.y = x, y
    self.id = love.math.random(1, 99999999)
    self.dead = false
    opts = opts or {}
    for k, v in pairs(opts) do self[k] = v end
end
