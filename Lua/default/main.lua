local moonshine = require 'moonshine'
local cam = require "camera"

function love.load()
    cam = cam.new(0,0,0.75,0,damped)
    shader = moonshine(moonshine.effects.pixelate)
    .chain(moonshine.effects.glow)

    shader.pixelate.size = 4
    shader.glow.min_luma = 0.5
    shader.glow.strength = 5
    
    love.window.setFullscreen(true)

    vw = love.graphics.getWidth()
    vh = love.graphics.getHeight()
    null = {}
    pi = 3.14159265359
    fps = 0
    upSpeed = 0.1 -- how often the fps updates
    upElapsed = 0 -- will be added onto until larger than upSpeed and resets
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
            love.event.quit()           -- quit game
    end
end

function love.update(dt)
    -- fps handling --
    upElapsed = upElapsed + dt -- adds the time between two frames
    if (upElapsed > upSpeed) then
        fps = math.floor(1 / dt) -- get the frames per second
        upElapsed = 0
    end
end

function love.draw()
    shader(function()
        love.graphics.setDefaultFilter("nearest")
        cam:attach()
            love.graphics.rectangle("fill",100,100,100,100)
        cam:detach()
    end)
end