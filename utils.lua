-- Small helpers shared across the game.

function math.dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function math.clamp(v, lo, hi)
    return math.max(lo, math.min(v, hi))
end

function chance(p)
    return love.math.random() < p
end

-- Inverse of the main draw: map a mouse position in window pixels to canvas
-- pixels given the centered aspect-preserving scale used when presenting.
function getViewTransform()
    local winW, winH = love.graphics.getDimensions()
    local scale = math.min(winW / gw, winH / gh)
    local ox = (winW - gw * scale) / 2
    local oy = (winH - gh * scale) / 2
    return ox, oy, scale
end

-- Returns true if a circle at (x, y) with radius r overlaps any wall tile.
-- grid is row-major: grid[ty][tx], value 1 == wall.
-- Global because objects (e.g. Bullet) call it directly.
function collidesWithWalls(grid, x, y, r)
    local x0 = math.floor((x - r) / tile)
    local x1 = math.floor((x + r) / tile)
    local y0 = math.floor((y - r) / tile)
    local y1 = math.floor((y + r) / tile)
    for ty = y0, y1 do
        local row = grid[ty]
        if row then
            for tx = x0, x1 do
                if row[tx] == 1 then return true end
            end
        end
    end
    return false
end

-- Axis-separated movement against the tilemap. Tries X then Y so the object
-- slides along walls instead of sticking on corners.
function moveAgainstWalls(grid, obj, dx, dy)
    if not collidesWithWalls(grid, obj.x + dx, obj.y, obj.radius) then
        obj.x = obj.x + dx
    end
    if not collidesWithWalls(grid, obj.x, obj.y + dy, obj.radius) then
        obj.y = obj.y + dy
    end
end
