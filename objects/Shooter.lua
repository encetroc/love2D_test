Shooter = GameObject:extend()

function Shooter:init(area, x, y, opts)
    self.hp = 22
    self.speed = 55
    self.radius = 10
    self.color = { 0.62, 0.35, 0.95 }
    self.shootcd = 1.0
    self.desired = 150
    Shooter.super.init(self, area, x, y, opts)
end

function Shooter:update(dt)
    local dx, dy = self.kx or 0, self.ky or 0
    local p = self.area:getPlayer()
    if p and not p.dead then
        local ang = math.atan2(p.y - self.y, p.x - self.x)
        local d = math.dist(self.x, self.y, p.x, p.y)
        local mv = 0
        if d > self.desired + 20 then mv = 1 elseif d < self.desired - 20 then mv = -1 end
        dx = dx + math.cos(ang) * self.speed * mv
        dy = dy + math.sin(ang) * self.speed * mv
        if math.abs(d - self.desired) < 40 then
            dx = dx + math.cos(ang + math.pi / 2) * self.speed * 0.5
            dy = dy + math.sin(ang + math.pi / 2) * self.speed * 0.5
        end
        self.shootcd = self.shootcd - dt
        if self.shootcd <= 0 and d < 240 then
            self.shootcd = 1.7
            self.area:addGameObject('Bullet',
                self.x + math.cos(ang) * 12, self.y + math.sin(ang) * 12,
                { r = ang, speed = 155, team = 'enemy', damage = 12 })
            sfx.enemyshoot()
        end
    end
    moveAgainstWalls(self.area.room.grid, self, dx * dt, dy * dt)
    if self.kx then
        self.kx = self.kx * (1 - 5 * dt)
        self.ky = self.ky * (1 - 5 * dt)
    end
end

function Shooter:damage(amount, source)
    if self.dead then return end
    self.hp = self.hp - amount
    if source then
        local ang = math.atan2(self.y - source.y, self.x - source.x)
        self.kx = (self.kx or 0) + math.cos(ang) * 150
        self.ky = (self.ky or 0) + math.sin(ang) * 150
    end
    if self.hp <= 0 then
        self.dead = true
        self.area.room:onEnemyDeath(self)
    end
end

function Shooter:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle('fill', self.x, self.y, self.radius)
    local p = self.area:getPlayer()
    local ang = 0
    if p and not p.dead then ang = math.atan2(p.y - self.y, p.x - self.x) end
    love.graphics.setColor(0.15, 0.1, 0.3)
    love.graphics.rectangle('fill', self.x - 2, self.y - 2, 2, 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill',
        self.x + math.cos(ang) * 12 - 6, self.y + math.sin(ang) * 12, 2)
    love.graphics.circle('fill',
        self.x + math.cos(ang) * 12 + 6, self.y + math.sin(ang) * 12, 2)
end
