Key = GameObject:extend()

function Key:init(area, x, y, opts)
    self.t = 0
    self.radius = 9
    Key.super.init(self, area, x, y, opts)
end

function Key:update(dt)
    self.t = self.t + dt
    local p = self.area:getPlayer()
    if p and not p.dead and math.dist(self.x, self.y, p.x, p.y) < 15 + p.radius then
        p.haskey = true
        self.dead = true
        sfx.key()
        self.area.room:burst(self.x, self.y, { 1, 0.85, 0.25 }, 16, 0.4, 1)
    end
end

function Key:draw()
    local bob = math.sin(self.t * 6) * 2
    love.graphics.setColor(0.15, 0.12, 0.08)
    love.graphics.circle('fill', self.x, self.y + bob, 8)
    love.graphics.setColor(1, 0.82, 0.15)
    love.graphics.circle('line', self.x, self.y + bob - 5, 5, 12)
    love.graphics.circle('fill', self.x, self.y + bob - 5, 2.4)
    love.graphics.rectangle('fill', self.x - 1.5, self.y + bob - 5, 3, 12)
    love.graphics.rectangle('fill', self.x - 3.5, self.y + bob + 4, 5, 3)
end
