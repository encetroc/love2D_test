-- Fixed low-res base resolution. The window scales up from this; it divides
-- cleanly so shapes stay crisp under a 'nearest' filter.
gw, gh = 480, 270

-- World is tiled; this is the size of one wall/floor tile in world pixels.
tile = 32

-- Enemy class names, used everywhere the game asks "is this an enemy?".
enemies_classes = { 'Grunt', 'Shooter' }

function isEnemy(obj)
    for i = 1, #enemies_classes do
        if obj:is(_G[enemies_classes[i]]) then return true end
    end
    return false
end
