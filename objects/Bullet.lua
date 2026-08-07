Bullet = GameObject:extend()

function Bullet:init(area, x, y, opts)
    self.radius = 4
    self.damage = 12
    self.life = 0
    Bullet.super.init(self, area, x, y, opts)
end

function Bullet:update(dt)
    local grid = self.area.room.grid
    local dx = math.cos(self.r) * self.speed * dt
    local dy = math.sin(self.r) * self.speed * dt
    if collidesWithWalls(grid, self.x + dx, self.y, self.radius) then self:impact(); return end
    if collidesWithWalls(grid, self.x, self.y + dy, self.radius) then self:impact(); return end
    self.x = self.x + dx
    self.y = self.y + dy

    if self.team == 'player' then
        local enemies = self.area:getAllGameObjectsThat(isEnemy)
        for i = 1, #enemies do
            local e = enemies[i]
            if not e.dead and math.dist(self.x, self.y, e.x, e.y) < self.radius + e.radius then
                e:damage(self.damage, self)
                self:impact()
                return
            end
        end
    else
        local p = self.area:getPlayer()
        if p and not p.dead and math.dist(self.x, self.y, p.x, p.y) < self.radius + p.radius then
            p:damage(self.damage, self)
            self:impact()
            return
        end
    end

    self.life = self.life + dt
    if self.life > 2.5 then self.dead = true end
end

function Bullet:impact()
    self.dead = true
    self.area.room:burst(self.x, self.y, { 1, 0.95, 0.45 }, 5, 0.22, 1)
end

function Bullet:draw()
    local ang = self.r
    local tx = self.x - math.cos(ang) * 8
    local ty = self.y - math.sin(ang) * 8
    love.graphics.setColor(1, 0.9, 0.5, 0.35)
    love.graphics.line(self.x, self.y, tx, ty)
    love.graphics.setColor(1, 0.95, 0.4)
    love.graphics.circle('fill', self.x, self.y, self.radius)
end
