-- The play room. Generates a dungeon, runs the object area, and draws the
-- world onto a low-res canvas that is then scaled up to the window.

Stage = Object:extend()

function Stage:init(level, carryHp)
    self.level = level or 1
    self.carryHp = carryHp or nil
    self.state = 'play'
    self.shake = 0
    self.canvas = love.graphics.newCanvas(gw, gh)
    self.camera = Camera.new(gw, gh)
    self.font = love.graphics.newFont(9)
    self.bigfont = love.graphics.newFont(16)
    self:newLevel()
end

function Stage:newLevel()
    local rcount = math.min(6 + self.level, 14)
    local gen = generateDungeon(love.math.random(1, 999999), rcount)
    self.grid = gen.grid
    self.worldW = gen.worldW
    self.worldH = gen.worldH
    self.area = Area:new(self)

    local s = gen.spawn
    self.player = self.area:addGameObject('Player', s.x, s.y)
    if self.carryHp then
        self.player.hp = math.min(self.player.max_hp, self.carryHp + 25)
    end

    self.area:addGameObject('Key', gen.key.x, gen.key.y)
    self.area:addGameObject('Door', gen.door.x, gen.door.y)

    local count = math.min(4 + math.floor(self.level * 1.6), #gen.enemySpots)
    for i = 1, count do
        local t = gen.enemySpots[i]
        local cls = (i % 3 == 0) and 'Shooter' or 'Grunt'
        self.area:addGameObject(cls, t.x, t.y, {})
    end
end

function Stage:advanceLevel()
    sfx.level()
    local hp = self.player and self.player.hp or self.player.max_hp
    gotoRoom('Stage', self.level + 1, hp)
end

function Stage:gameOver()
    self.state = 'gameover'
    sfx.hurt()
end

function Stage:onEnemyDeath(e)
    self:burst(e.x, e.y, e.color or { 1, 1, 1 }, 12, 0.35, 1)
    sfx.hit()
    if chance(0.15) then
        self.area:addGameObject('Pickup', e.x, e.y, { kind = 'health' })
    end
end

function Stage:burst(x, y, color, count, life, spread)
    for i = 1, (count or 6) do
        local ang = love.math.random() * math.pi * 2
        local sp = love.math.random(20, 40 + (spread or 50) * 50)
        self.area:addGameObject('Particle', x, y, {
            vx = math.cos(ang) * sp,
            vy = math.sin(ang) * sp,
            color = color,
            life = life or 0.3,
            radius = love.math.random(1, 3),
        })
    end
end

function Stage:update(dt)
    if self.state == 'gameover' then
        if love.keyboard.wasPressed('r') then gotoRoom('Stage', 1) end
        return
    end
    self.camera:follow(self.player.x, self.player.y, self.worldW, self.worldH)
    if self.shake > 0 then self.shake = self.shake - dt end
    self.area:update(dt)
end

function Stage:drawTiles()
    love.graphics.setColor(0.10, 0.10, 0.14)
    love.graphics.rectangle('fill', 0, 0, self.worldW, self.worldH)
    for ty = 1, #self.grid do
        local row = self.grid[ty]
        for tx = 1, #row do
            if row[tx] == 1 then
                love.graphics.setColor(0.26, 0.24, 0.34)
                love.graphics.rectangle('fill', (tx - 1) * tile, (ty - 1) * tile, tile, tile)
                love.graphics.setColor(0.33, 0.31, 0.42)
                love.graphics.rectangle('fill', (tx - 1) * tile, (ty - 1) * tile, tile, 3)
            elseif (tx + ty) % 2 == 0 then
                love.graphics.setColor(0.12, 0.12, 0.16)
                love.graphics.rectangle('fill', (tx - 1) * tile, (ty - 1) * tile, tile, tile)
            end
        end
    end
end

function Stage:drawHUD()
    if self.state == 'gameover' then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        love.graphics.setFont(self.bigfont)
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf('YOU DIED', 0, gh / 2 - 34, gw, 'center')
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf('Reached level ' .. self.level .. '   Press R to restart', 0, gh / 2 - 6, gw, 'center')
        return
    end

    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('LEVEL ' .. self.level, 6, 4)

    local keyState = (self.player and self.player.haskey) and 'KEY: LOCKED DOOR IS OPEN' or 'KEY: ???'
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(keyState, 6, 17)

    if self.player then
        local pw, ph, px, py = 120, 10, 10, gh - 20
        local ratio = math.max(0, self.player.hp / self.player.max_hp)
        love.graphics.setColor(0.2, 0.2, 0.26)
        love.graphics.rectangle('fill', px, py, pw, ph)
        love.graphics.setColor(0.9, 0.22, 0.22)
        love.graphics.rectangle('fill', px, py, pw * ratio, ph)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', px - 1, py - 1, pw + 2, ph + 2)
    end

    if self.level == 1 then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf('WASD move | mouse aim | LMB shoot | find the KEY, take it to the DOOR',
            0, gh - 34, gw, 'center')
    end
end

function Stage:draw()
    -- 1. render world + HUD onto the low-res canvas
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.push()
    self.camera:apply()
    if self.shake > 0 then
        love.graphics.translate(love.math.random(-3, 3) * self.shake * 4, love.math.random(-3, 3) * self.shake * 4)
    end
    self:drawTiles()
    self.area:draw()
    love.graphics.pop()
    self:drawHUD()
    love.graphics.setCanvas()

    -- 2. present the canvas scaled, centered, aspect preserved
    local winW, winH = love.graphics.getDimensions()
    local scale = math.min(winW / gw, winH / gh)
    local ox = (winW - gw * scale) / 2
    local oy = (winH - gh * scale) / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, ox, oy, 0, scale, scale)
end
