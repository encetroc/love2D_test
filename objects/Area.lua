-- Owns and updates all shared objects in a Stage. Removes dead objects.
Area = Object:extend()

function Area:init(room)
    self.room = room
    self.game_objects = {}
end

function Area:addGameObject(type, x, y, opts)
    local obj = _G[type](self, x, y, opts or {})
    table.insert(self.game_objects, obj)
    return obj
end

function Area:getPlayer()
    return self.room.player
end

function Area:getAllGameObjectsThat(fn)
    local res = {}
    for i = 1, #self.game_objects do
        local o = self.game_objects[i]
        if fn(o) then res[#res + 1] = o end
    end
    return res
end

function Area:update(dt)
    -- iterate backwards so removing dead objects never skips an entry
    for i = #self.game_objects, 1, -1 do
        local o = self.game_objects[i]
        o:update(dt)
        if o.dead then table.remove(self.game_objects, i) end
    end
end

function Area:draw()
    for i = 1, #self.game_objects do
        local o = self.game_objects[i]
        if not o.dead and o.draw then o:draw() end
    end
end
