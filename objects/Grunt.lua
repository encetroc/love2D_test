Grunt = GameObject:extend()

function Grunt:init(area, x, y, opts)
    self.hp = 34
    self.speed = 75 + love.math.random(-5, 12)
    self.radius = 11
    self.color = { 0.92, 0.28, 0.2 }
    Grunt.super.init(self, area, x, y, opts)
end

function Grunt:update(dt)
    local dx, dy = self.kx or 0, self.ky or 0
    local p = self.area:getPlayer()
    if p and not p.dead then
        local ang = math.atan2(p.y - self.y, p.x - self.x)
        dx = dx + math.cos(ang) * self.speed
        dy = dy + math.sin(ang) * self.speed
    end
    moveAgainstWalls(self.area.room.grid, self, dx * dt, dy * dt)
    if self.kx then
        self.kx = self.kx * (1 - 5 * dt)
        self.ky = self.ky * (1 - 5 * dt)
    end
    if p and not p.dead and math.dist(self.x, self.y, p.x, p.y) < self.radius + p.radius then
        p:damage(10, self)
    end
end

function Grunt:damage(amount, source)
    if self.dead then return end
    self.hp = self.hp - amount
    if source then
        local ang = math.atan2(self.y - source.y, self.x - source.x)
        self.kx = (self.kx or 0) + math.cos(ang) * 170
        self.ky = (self.ky or 0) + math.sin(ang) * 170
    end
    if self.hp <= 0 then
        self.dead = true
        self.area.room:onEnemyDeath(self)
    end
end

function Grunt:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle('fill', self.x, self.y, self.radius)
    local p = self.area:getPlayer()
    local ang = 0
    if p and not p.dead then ang = math.atan2(p.y - self.y, p.x - self.x) end
    local ex = math.cos(ang) * 4
    local ey = math.sin(ang) * 4
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x + ex - 3, self.y + ey, 2.4)
    love.graphics.circle('fill', self.x + ex + 3, self.y + ey, 2.4)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('fill', self.x + ex - 3, self.y + ey, 1.2)
    love.graphics.circle('fill', self.x + ex + 3, self.y + ey, 1.2)
end
