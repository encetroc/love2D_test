function love.conf(t)
    t.identity = "pi_roguelike"
    t.version = "11.5"
    t.window.title = "Rogue Shooter"
    t.window.width = 960
    t.window.height = 540
    t.window.vsync = 1
    t.window.resizable = true
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
end
