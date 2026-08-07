Particle = GameObject:extend()

function Particle:init(area, x, y, opts)
    self.vx, self.vy = 0, 0
    self.life = 0.3
    self.maxlife = self.life
    self.radius = 2
    self.color = { 1, 1, 1 }
    Particle.super.init(self, area, x, y, opts)
end

function Particle:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.vx = self.vx * (1 - 4 * dt)
    self.vy = self.vy * (1 - 4 * dt)
    self.life = self.life - dt
    if self.life <= 0 then self.dead = true end
end

function Particle:draw()
    local a = math.max(0, self.life / self.maxlife)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], a)
    love.graphics.circle('fill', self.x, self.y, self.radius * a)
end
