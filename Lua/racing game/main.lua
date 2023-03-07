function love.load()
    
    cam = require "camera"
    cam = cam.new(0,0,0.75)

    camera = {
        zoom = 1,
        buffer = "null"
    }
    gameSettings = {
        shaders = {
            1,
            0,
        },
        cam = {
            rotate = false
        },
        buffer = "null"
    }

    sprites = {
        r = love.graphics.newImage("Sprites/r1.png"),
        b = love.graphics.newImage("Sprites/r2.png"),
        y = love.graphics.newImage("Sprites/r3.png"),
        g = love.graphics.newImage("Sprites/r4.png"),
        p = love.graphics.newImage("Sprites/r5.png"),
        k = love.graphics.newImage("Sprites/r6.png"),
        rb = love.graphics.newImage("Sprites/r7.png"),
        bb = love.graphics.newImage("Sprites/r8.png"),
        yb = love.graphics.newImage("Sprites/r9.png"),
        gb = love.graphics.newImage("Sprites/r10.png"),
        pb = love.graphics.newImage("Sprites/r11.png"),
        kb = love.graphics.newImage("Sprites/r12.png"),
        grid = love.graphics.newImage("Sprites/grid bg.png"),
        gridQuad = love.graphics.newQuad(-2000,-2000,4000,4000,256,256),
        buffer = "null"
    }

    drift = {
        amount = 0.25,
        sens = 0.01
    }
    
    player1 = {
        -- dynamic vars
        x_vel = 0,
        y_vel = 0,
        x_pos = 0,
        y_pos = 0,
        angle = 0,
        speed = 0,
        speedUp = 0,
        drift = false,
        driftAmount = drift.amount,
        
        -- static vars
        size = 20,
        acceleration = 1.1,
        deceleration = 1.02,
        turnSens = 2,
        sprite = sprites.r
    }
    
    
    heatSettings = {
        cc = 100,
        map = {
            -- all arrays are formated as follows
            -- start X, start Y, image texture, ...
            test = {
                startPos = {100,100},
                image = love.graphics.newImage("maps/test track.png"),
                buffer = "null"
            },
            buffer = "null"
        },
        ai = false,
    }
    
    sprites.grid:setWrap("repeat","repeat")

    pi = 3.14159265359
    fps = 0
    upSpeed = 0.1 -- how often the fps updates
    upElapsed = 0 -- will be added onto until larger than upSpeed and resets
    test = 0
end

-- START THE GAME --
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
    -- actual controlls
    if love.keyboard.isDown('d') then
        player1.angle = player1.angle + player1.turnSens
    end
    if love.keyboard.isDown('a') then
        player1.angle = player1.angle - player1.turnSens
    end

    if love.keyboard.isDown('w') then
        player1.speedUp = player1.speedUp + player1.acceleration
        player1.speed = math.log(player1.speedUp * (heatSettings.cc/100))
    else
        player1.speed = player1.speed / player1.deceleration
        player1.speedUp = 0
    end

    if love.keyboard.isDown('s') then
        if player1.speed > -1 * (heatSettings.cc/50) then
            player1.speed = ((1 + player1.speed) / (player1.deceleration * 1.2)) - 1
        end
    end

    if love.keyboard.isDown('lshift') then
        player1.drift = true
    else
        player1.drift = false
    end
    
    if player1.drift then
        player1.driftAmount = drift.sens
        player1.sprite = sprites.rb
    else
        --                    modify                ((difference) * half of a modifier)
        player1.driftAmount = player1.driftAmount - ((player1.driftAmount - drift.amount) * (0.5 * drift.sens))
        player1.sprite = sprites.r
    end

    -- update direction
    player1.x_vel = player1.x_vel - ((player1.x_vel - math.cos(((player1.angle)*pi)/180)) * player1.driftAmount)
    player1.y_vel = player1.y_vel - ((player1.y_vel - math.sin(((player1.angle)*pi)/180)) * player1.driftAmount)
    
    -- move player
    player1.x_pos = player1.x_pos + (player1.x_vel * player1.speed)
    player1.y_pos = player1.y_pos + (player1.y_vel * player1.speed)
end

-- DEBUG CONTROLLS --
function debugger()
    if love.keyboard.isDown('r') then
        player1.x_pos = 100
        player1.y_pos = 100
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

    -- functions --
    control()
    debugger()
    cam:lookAt(player1.x_pos,player1.y_pos)
    cam:zoomTo(camera.zoom)
    if gameSettings.cam.rotate then
        cam:rotateTo(-((player1.angle+90)*pi)/180)
    end
end

-- DRAWS EVERY FRAME --
function love.draw()
    
    cam:attach()
    -- bg --
    love.graphics.draw(sprites.grid,sprites.gridQuad,-2000,-2000,0,1,1)
    love.graphics.draw(heatSettings.map.test.image,-2000,-2000,0,1,1)
    
    -- player 1 --
    love.graphics.draw(
        player1.sprite,
        player1.x_pos,
        player1.y_pos,
        ((player1.angle-90)*pi)/180,
        player1.size/100,
        player1.size/100,
        player1.sprite:getWidth()/2,
        player1.sprite:getHeight()/2
    )
    cam:detach()

    love.graphics.print("FPS: "..fps,0,0)
    love.graphics.print("x_vel: "..player1.x_vel,0,20)
    love.graphics.print("y_vel: "..player1.y_vel,0,40)
    love.graphics.print("x_pos: "..player1.x_pos,0,60)
    love.graphics.print("y_pos: "..player1.y_pos,0,80)
    love.graphics.print("angle: "..player1.angle,0,100)
    love.graphics.print("speed: "..player1.speed,0,120)
    love.graphics.print("drift: "..tostring(player1.drift),0,140)
    love.graphics.print("driftAmount: "..player1.driftAmount,0,160)
end