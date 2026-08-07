-- Procedural dungeon generation. Builds a grid of rooms connected by
-- L-shaped corridors and computes the spawn/door/key/enemy placement points.
-- All coordinates returned are world pixels (tile centers).

local TILE = tile

function generateDungeon(seed, targetRooms)
    love.math.setRandomSeed(seed)

    local cols, rows = 38, 28
    -- row-major grid, 1 == wall
    local grid = {}
    for y = 1, rows do
        grid[y] = {}
        for x = 1, cols do grid[y][x] = 1 end
    end

    -- 1. carve non-overlapping rooms
    local rooms = {}
    local attempts = 0
    while #rooms < targetRooms and attempts < 120 do
        attempts = attempts + 1
        local w = love.math.random(4, 8)
        local h = love.math.random(3, 6)
        local x = love.math.random(2, cols - w - 2)
        local y = love.math.random(2, rows - h - 2)
        local nr = { x = x, y = y, w = w, h = h }
        local overlap = false
        for i = 1, #rooms do
            local r = rooms[i]
            if not (nr.x + nr.w < r.x - 1 or r.x + r.w < nr.x - 1 or
                    nr.y + nr.h < r.y - 1 or r.y + r.h < nr.y - 1) then
                overlap = true
                break
            end
        end
        if not overlap then rooms[#rooms + 1] = nr end
    end

    for i = 1, #rooms do
        local r = rooms[i]
        for x = r.x, r.x + r.w - 1 do
            for y = r.y, r.y + r.h - 1 do grid[y][x] = 0 end
        end
    end

    -- 2. connect consecutive room centers (couples the whole set into one cave)
    for i = 2, #rooms do
        connectRooms(grid, rooms[i - 1], rooms[i])
    end

    -- 3. collect floor tiles (world pixel centers)
    local floors = {}
    for y = 1, rows do
        for x = 1, cols do
            if grid[y][x] == 0 then
                floors[#floors + 1] = { x = (x - 0.5) * TILE, y = (y - 0.5) * TILE }
            end
        end
    end

    local d = function(a, b) return math.dist(a.x, a.y, b.x, b.y) end

    -- 4. spawn near map center
    local cx, cy = cols / 2 * TILE, rows / 2 * TILE
    local spawn = floors[1]
    local best = 1e9
    for i = 1, #floors do
        local dist = math.dist(floors[i].x, floors[i].y, cx, cy)
        if dist < best then best, spawn = dist, floors[i] end
    end

    -- 5. door at the floor tile farthest from spawn
    local door = spawn
    best = -1
    for i = 1, #floors do
        local dist = d(floors[i], spawn)
        if dist > best then best, door = dist, floors[i] end
    end

    -- 6. key far from both the door and the spawn
    local key = spawn
    best = -1
    for i = 1, #floors do
        local f = floors[i]
        local farFromDoor = d(f, door)
        local dist = math.min(farFromDoor, d(f, spawn))
        if dist > best and farFromDoor > 2 * TILE then best, key = dist, f end
    end

    -- 7. enemy spawn candidates away from the player
    local spots = {}
    for i = 1, #floors do
        if d(floors[i], spawn) > 150 then spots[#spots + 1] = floors[i] end
    end
    -- shuffle
    for i = #spots, 2, -1 do
        local j = love.math.random(i)
        spots[i], spots[j] = spots[j], spots[i]
    end

    return {
        grid = grid, cols = cols, rows = rows,
        worldW = cols * TILE, worldH = rows * TILE,
        spawn = spawn, door = door, key = key, enemySpots = spots,
    }
end

function connectRooms(grid, a, b)
    local ax = math.floor(a.x + a.w / 2)
    local ay = math.floor(a.y + a.h / 2)
    local bx = math.floor(b.x + b.w / 2)
    local by = math.floor(b.y + b.h / 2)
    local x, y = ax, ay
    -- pick corridor arm order randomly so layouts vary
    if love.math.random() > 0.5 then
        while x ~= bx do grid[y][x] = 0; x = x + (bx > x and 1 or -1) end
        while y ~= by do grid[y][x] = 0; y = y + (by > y and 1 or -1) end
    else
        while y ~= by do grid[y][x] = 0; y = y + (by > y and 1 or -1) end
        while x ~= bx do grid[y][x] = 0; x = x + (bx > x and 1 or -1) end
    end
end
