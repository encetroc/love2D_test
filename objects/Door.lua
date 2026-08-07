Door = GameObject:extend()

function Door:init(area, x, y, opts)
    self.w, self.h = 46, 46
    self.flash = 0
    Door.super.init(self, area, x, y, opts)
end

function Door:update(dt)
    self.flash = math.max(0, self.flash - dt)
    local p = self.area:getPlayer()
    if p and not p.dead then
        if math.dist(self.x, self.y, p.x, p.y) < self.w / 2 + p.radius then
            if p.haskey then
                self.area.room:advanceLevel()
            else
                self.flash = 0.4
                sfx.hurt()
            end
        end
    end
end

function Door:draw()
    local p = self.area:getPlayer()
    local open = p ~= nil and p.haskey
    love.graphics.setColor(0.28, 0.26, 0.38)
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
    if self.flash > 0 then
        love.graphics.setColor(1, 0.4, 0.2, 0.85)
    elseif open then
        love.graphics.setColor(0.35, 1, 0.45, 0.85)
    else
        love.graphics.setColor(0.95, 0.72, 0.2, 0.85)
    end
    love.graphics.rectangle('fill', self.x - self.w / 2 + 4, self.y - self.h / 2 + 4, self.w - 8, self.h - 8)

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 5)
    love.graphics.setColor(0.15, 0.13, 0.2)
    love.graphics.rectangle('fill', self.x - 2, self.y - 4, 4, 8)
    if open then
        love.graphics.setColor(0.35, 1, 0.45)
        love.graphics.circle('fill', self.x, self.y, 2)
    end
end
