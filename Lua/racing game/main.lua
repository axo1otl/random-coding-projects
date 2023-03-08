debug = false

function love.load() 
    cam = require "camera"
    cam = cam.new(0,0,0.75)

    trackData = love.image.newImageData("maps/test track.png")

    camera = {
        zoom = 1,
        buffer = "null"
    }

    canvas = love.graphics.newCanvas( )

    gameSettings = {
        shaders = {
            1,
            0,
        },
        cam = {
            rotate = false
        },
        scene = 0, -- 0: Title screen | 1: settings | 2: game | 3: pause
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
        amount = 0.5, -- 0.25
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
        on = trackData:getPixel(2000,2000),
        
        -- static vars
        size = 20,
        acceleration = 1.1,
        deceleration = 1.02,
        turnSens = 1.5,
        load = true,
        sprite = sprites.r,
        buffer = "null"
    }

    time = {
        out = 0,
        lap = 0,
        total = 0,
        laps = {
            l1 = 0,
            l2 = 0,
            l3 = 0,
            l4 = 0,
            l5 = 0},
        buffer = "null",
    }
    
    
    heatSettings = {
        cc = 100,
        map = {
            test = {
                startPos = {-480,-1380},
                linePos = {-380,-1380},
                image = love.graphics.newImage("maps/test track.png"),
                buffer = "null"
            },
            buffer = "null"
        },
        ai = false,
        mode = 1, -- 0: normal | 1: drift | 2: ???
        buffer = "null"
    }
    
    sprites.grid:setWrap("repeat","repeat")

    pi = 3.14159265359
    fps = 0
    upSpeed = 0.1 -- how often the fps updates
    upElapsed = 0 -- will be added onto until larger than upSpeed and resets
    test = 0
    newLap = false
end

-- CONTROLLING THE PLAYERS --
function control()
    if player1.load then
        player1.x_pos = heatSettings.map.test.startPos[1]
        player1.y_pos = heatSettings.map.test.startPos[2]
        player1.load = false
    end
    -- actual controls
    if love.keyboard.isDown('d') then
        player1.angle = player1.angle + player1.turnSens
    end
    if love.keyboard.isDown('a') then
        player1.angle = player1.angle - player1.turnSens
    end

    if love.keyboard.isDown('w') then
        player1.speedUp = player1.speedUp + player1.acceleration
        player1.speed = math.log(player1.speedUp * (heatSettings.cc/100))/2
    else
        player1.speed = player1.speed / player1.deceleration
        player1.speedUp = 0
    end

    if love.keyboard.isDown('s') then
        if player1.speed > -1 * (heatSettings.cc/50) then
            player1.speed = ((1 + player1.speed) / (player1.deceleration * 1.2)) - 1
        end
    end

    if love.keyboard.isDown('lshift') or heatSettings.mode == 1 then
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

-- NAVIGATION STUFF --
function menu()
    cam:lookAt(100,100)
    cam:zoomTo(camera.zoom)
    if love.keyboard.isDown('space') then
        gameSettings.scene = 2
    end
    if love.keyboard.isDown('return') then
        gameSettings.scene = 1
    end
end

function settings()
    -- idk
end

function game()
    if love.keyboard.isDown('escape') then
        gameSettings.scene = 0
    end
    cam:lookAt(player1.x_pos,player1.y_pos)

    time.lap = time.lap + upElapsed
    if player1.on == 0 then
        time.out = time.out + upElapsed
        timeOutAlpha = 1
    else
        timeOutAlpha = 0
    end

    if player1.on == 0.2 then
        time.total = time.total + time.lap + time.out * 4
        
        if time.laps.l1 == 0 then
            time.laps.l1 = time.total
        elseif time.laps.l2 == 0 then
            time.laps.l2 = time.lap + time.out * 4
        elseif time.laps.l3 == 0 then
            time.laps.l3 = time.lap + time.out * 4
        elseif time.laps.l4 == 0 then
            time.laps.l4 = time.lap + time.out * 4
        elseif time.laps.l5 == 0 then
            time.laps.l5 = time.lap + time.out * 4
        end

        time.lap = 0
        time.out = 0

        if newLap == false then
            time.laps.l1 = 0
            time.total = 0
            time.lap = 0
            time.out = 0
        end
        newLap = true
    end

end

function pause()
    if love.keyboard.isDown('escape') then
        gameSettings.scene = 2
    end 
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        if gameSettings.scene == 0 then 
            love.event.quit()
        end
        if gameSettings.scene == 2 then
            gameSettings.scene = 0
        end
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
    if gameSettings.scene == 0 then
        menu()
    end
    if gameSettings.scene == 2 then
        control()
        game()
    end
    if gameSettings.scene == 3 then
    end
    debugger()
    cam:zoomTo(camera.zoom)
    if gameSettings.cam.rotate then
        cam:rotateTo(-((player1.angle+90)*pi)/180)
    end
end

-- DRAWS EVERY FRAME --
function love.draw()
    player1.on = trackData:getPixel(player1.x_pos + 2000,player1.y_pos + 2000)
    local vw = love.graphics.getWidth()
    local vh = love.graphics.getHeight()

    
    cam:attach()
    -- bg --
    love.graphics.draw(sprites.grid,sprites.gridQuad,-2000,-2000,0,1,1)
    if gameSettings.scene == 0 then
        love.graphics.print("Press space to play",-200,10,0,2,2)
    end
    if gameSettings.scene == 2 then
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
    end

    cam:detach()
    
    love.graphics.setColor(1,0,0,timeOutAlpha)
    love.graphics.print(""..time.out,20,60)
    love.graphics.setColor(1,1,1,0.75)
    love.graphics.print(""..time.lap,20,40,0,1.1,1.1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(""..time.total,20,20,0,1.25,1.25)

    love.graphics.print(""..time.laps.l1,20,100,0,1,1)
    love.graphics.print(""..time.laps.l2,20,120,0,1,1)
    love.graphics.print(""..time.laps.l3,20,140,0,1,1)
    love.graphics.print(""..time.laps.l4,20,160,0,1,1)
    love.graphics.print(""..time.laps.l5,20,180,0,1,1)

    if debug then
        love.graphics.print("FPS: "..fps,0,0)
        love.graphics.print("x_vel: "..player1.x_vel,0,20)
        love.graphics.print("y_vel: "..player1.y_vel,0,40)
        love.graphics.print("x_pos: "..player1.x_pos,0,60)
        love.graphics.print("y_pos: "..player1.y_pos,0,80)
        love.graphics.print("angle: "..player1.angle,0,100)
        love.graphics.print("speed: "..player1.speed,0,120)
        love.graphics.print("drift: "..tostring(player1.drift),0,140)
        love.graphics.print("driftAmount: "..player1.driftAmount,0,160)
        love.graphics.print("scene: "..gameSettings.scene,0,180)
        love.graphics.print("pixel: "..player1.on,0,200)
    end
end