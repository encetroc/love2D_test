-- Entry point. Pulls globals/libraries/objects/rooms in a fixed, safe order,
-- then delegates to the active room each frame.

Object = require 'lib/classic'
Camera = require 'lib/camera'
sfx = require 'lib/sfx'
require 'globals'
require 'utils'
require 'level'

require 'objects/GameObject'
require 'objects/Area'
require 'objects/Player'
require 'objects/Bullet'
require 'objects/Grunt'
require 'objects/Shooter'
require 'objects/Key'
require 'objects/Door'
require 'objects/Pickup'
require 'objects/Particle'
require 'rooms/Stage'

current_room = nil

function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.keyboard.setKeyRepeat(false)
    gotoRoom('Stage', 1)
end

function love.update(dt)
    if current_room then current_room:update(dt) end
end

function love.draw()
    love.graphics.clear(0.02, 0.02, 0.04)
    if current_room then current_room:draw() end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
end
