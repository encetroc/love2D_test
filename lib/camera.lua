-- A tiny 2D camera that follows a target and clamps to the world bounds.
local Camera = {}
Camera.__index = Camera

function Camera.new(viewW, viewH)
    return setmetatable({ x = 0, y = 0, viewW = viewW, viewH = viewH }, Camera)
end

function Camera:follow(fx, fy, worldW, worldH)
    local tx = fx - self.viewW / 2
    local ty = fy - self.viewH / 2
    if worldW <= self.viewW then
        tx = (worldW - self.viewW) / 2
    else
        tx = math.max(0, math.min(tx, worldW - self.viewW))
    end
    if worldH <= self.viewH then
        ty = (worldH - self.viewH) / 2
    else
        ty = math.max(0, math.min(ty, worldH - self.viewH))
    end
    self.x, self.y = tx, ty
end

function Camera:apply()
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

return Camera
