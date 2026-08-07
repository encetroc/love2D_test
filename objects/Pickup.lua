Pickup = GameObject:extend()

function Pickup:init(area, x, y, opts)
    self.t = 0
    self.radius = 7
    Pickup.super.init(self, area, x, y, opts)
end

function Pickup:update(dt)
    self.t = self.t + dt
    local p = self.area:getPlayer()
    if p and not p.dead and p.hp < p.max_hp and math.dist(self.x, self.y, p.x, p.y) < 12 + p.radius then
        p.hp = math.min(p.max_hp, p.hp + 30)
        self.dead = true
        sfx.pickup()
    end
end

function Pickup:draw()
    local s = 1 + math.sin(self.t * 5) * 0.15
    love.graphics.setColor(0.3, 1, 0.4)
    love.graphics.circle('fill', self.x, self.y, 7 * s)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x - 6, self.y - 1.5, 12, 3)
    love.graphics.rectangle('fill', self.x - 1.5, self.y - 6, 3, 12)
end
