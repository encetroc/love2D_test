-- Minimal object-orientation (drop-in subset of rxi/classic).
-- Classes are globals: requiring an object file binds ClassName globally.
local Object = {}
Object.__index = Object

-- Let a class be called directly: ClassName(...) == ClassName:new(...). Each
-- subclass's own metatable carries a copy, so this works at any depth.
Object.__call = function(cls, ...)
    return cls:new(...)
end

function Object:extend()
    local cls = {}
    -- Copy the parent's methods/class-fields, but never its dunder keys.
    for k, v in pairs(self) do
        if k:find("__") ~= 1 then cls[k] = v end
    end
    cls.__index = cls
    cls.super = self  -- set AFTER the copy loop: the loop would otherwise
                      -- overwrite super with the parent's super (grandparent).
    -- Per-class metatable: __index -> parent for inherited-method lookup and
    -- this class's OWN __call. Lua looks up __call as a raw key of the class's
    -- metatable, so it must live here, not only on Object (a grandchild's
    -- metatable is its parent, not Object).
    setmetatable(cls, {
        __index = self,
        __call = Object.__call,
    })
    return cls
end

function Object:new(...)
    local instance = setmetatable({}, self)
    rawset(instance, '__class', self)  -- so :is() can find the class chain
    if instance.init then instance:init(...) end
    return instance
end

-- Works whether called on a class or on an instance (class vs instance is told
-- apart by the raw __class tag that :new() stamps on instances).
function Object:is(other)
    local cls = rawget(self, '__class')
    if not cls then cls = self end
    while cls do
        if cls == other then return true end
        cls = cls.super
    end
    return false
end

return Object
