Player = GameObject:extend()

Player.max_hp = 100
Player.speed = 135
Player.radius = 9
Player.fire_rate = 0.17

function Player:init(area, x, y, opts)
    self.hp = self.max_hp
    self.r = 0
    self.invuln = 0
    self.kx, self.ky = 0, 0
    self.fire = 0
    self.haskey = false
    Player.super.init(self, area, x, y, opts)
end

function Player:getAimAngle()
    local mx, my = love.mouse.getPosition()
    local ox, oy, scale = getViewTransform()
    local cx = (mx - ox) / scale
    local cy = (my - oy) / scale
    local wx = cx + self.area.room.camera.x
    local wy = cy + self.area.room.camera.y
    return math.atan2(wy - self.y, wx - self.x)
end

function Player:update(dt)
    self.r = self:getAimAngle()

    local dx, dy = 0, 0
    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then dx = dx - 1 end
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then dx = dx + 1 end
    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then dy = dy - 1 end
    if love.keyboard.isDown('s') or love.keyboard.isDown('down') then dy = dy + 1 end
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then dx, dy = dx / len, dy / len end

    local grid = self.area.room.grid
    moveAgainstWalls(grid, self, (dx * self.speed + self.kx) * dt, (dy * self.speed + self.ky) * dt)
    self.kx = self.kx * (1 - 6 * dt)
    self.ky = self.ky * (1 - 6 * dt)

    if self.invuln > 0 then self.invuln = self.invuln - dt end

    if love.mouse.isDown(1) then
        self.fire = self.fire - dt
        if self.fire <= 0 then
            self.fire = self.fire_rate
            local bx = self.x + math.cos(self.r) * 12
            local by = self.y + math.sin(self.r) * 12
            self.area:addGameObject('Bullet', bx, by, { r = self.r, speed = 290, team = 'player', damage = 14 })
            sfx.shoot()
        end
    else
        self.fire = 0
    end
end

function Player:damage(amount, source)
    if self.invuln > 0 or self.dead then return end
    self.hp = self.hp - amount
    self.invuln = 0.6
    self.area.room.shake = 0.25
    if source then
        local ang = math.atan2(self.y - source.y, self.x - source.x)
        self.kx = self.kx + math.cos(ang) * 220
        self.ky = self.ky + math.sin(ang) * 220
    end
    sfx.hurt()
    if self.hp <= 0 then
        self.hp = 0
        self.dead = true
        self.area.room:gameOver()
    end
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.r)
    love.graphics.setColor(0.25, 0.85, 0.95)
    love.graphics.polygon('fill', 0, -10, 15, 0, 0, 10, -7, 6, -7, -6)
    love.graphics.setColor(0.9, 0.97, 1)
    love.graphics.rectangle('fill', 7, -2.5, 6, 5)
    love.graphics.pop()

    if self.invuln > 0 then
        love.graphics.setColor(0.3, 0.8, 1, 0.5)
        love.graphics.circle('line', self.x, self.y, self.radius + 3)
    end
    if self.haskey then
        love.graphics.setColor(1, 0.85, 0.25, 0.95)
        love.graphics.circle('fill', self.x, self.y - 17, 3)
    end
end
