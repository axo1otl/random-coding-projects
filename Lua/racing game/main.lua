function love.load()
    gameSettings = {
        shaders = {
            1,
            0,
        }
    }

    player1 = {
        x_vel = 0,
        y_vel = 0,
        x_pos = 0,
        y_pos = 0,
        angle = 0,
        size = 20,
        speed = 0,
        sprite = love.graphics.newImage("Sprites/r1.png")
    }

    heatSettings = {
        cc = 100,
        map = {
          -- all arrays are formated as follows
          -- start X, start Y, image texture, ...
            {100,100,"maps/matrix.png"}
        },
        ai = false,
    }

    fps = 0
    upSpeed = 0.1 -- how often the fps updates
    upElapsed = 0 -- will be added onto until larger than upSpeed and resets
end

function heatStart(map)

end

-- QUITTING THE GAME --
function love.keypressed(key,scancode)

    if (scancode == "escape") then
        love.event.quit() -- closes game
    end

end

-- CONTROLLING THE PLAYERS --
function control()
    if love.keypressed("d") then
        player1.angle = player1.angle - 1
        player1.x_pos = player1.x_pos + 1
    end
end

-- UPDATES EVERY FRAME --
function love.update(dt)
    -- fps handling --
    upElapsed = upElapsed + dt -- adds the time between two frames
    if (upElapsed > upSpeed) then
        fps = math.floor(1 / dt) -- get the frames per second
        upElapsed = 0
    end
    control()
    player1.angle = player1.angle + 1
end

-- DRAWS EVERY FRAME --
function love.draw()
    -- fps --
    love.graphics.print("FPS: "..fps,0,0)
    
    -- player 1 --
    love.graphics.draw(
        player1.sprite,
        player1.x_pos + 100,
        player1.y_pos + 100,
        player1.angle, --default player1.angle
        player1.size/18 --default 180
    )
    love.graphics.print("Angle: "..player1.angle,100,0)
end