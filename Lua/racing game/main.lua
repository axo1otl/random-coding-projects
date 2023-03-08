debug = true
--debug = false

function love.load() 
    cam = require "camera"
    cam = cam.new(0,0,0.75)

    
    camera = {
        zoom = 1,
        buffer = "null"
    }

    heatSettings = {
        cc = 100,
        map = {
            test = {
                startPos = {-480,-1380},
                image = love.graphics.newImage("maps/test track.png"),
                trackData = love.image.newImageData("maps/test track.png"),
                checkScore = 0,
                buffer = "null"
            },
            test2 = {
                startPos = {-550,-1250},
                image = love.graphics.newImage("maps/test 2.png"),
                trackData = love.image.newImageData("maps/test 2.png"),
                checkScore = 5,
                buffer = "null"
            },
            buffer = "null"
        },
        ai = false,
        mode = 1, -- 0: normal | 1: drift | 2: ???
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
        track = heatSettings.map.test2,
        scene = 0, -- 0: Title screen | 1: settings | 2: game | 3: pause | 4: score table
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
    
    p1 = {
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
        on = gameSettings.track.trackData:getPixel(2000,2000),
        check = 0,
        
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
    if p1.load then
        p1.x_pos = gameSettings.track.startPos[1]
        p1.y_pos = gameSettings.track.startPos[2]
        p1.load = false
    end
    -- actual controls
    if love.keyboard.isDown('d') then
        p1.angle = p1.angle + p1.turnSens
    end
    if love.keyboard.isDown('a') then
        p1.angle = p1.angle - p1.turnSens
    end

    if love.keyboard.isDown('w') then
        p1.speedUp = p1.speedUp + p1.acceleration
        p1.speed = math.log(p1.speedUp * (heatSettings.cc/100))/2
    else
        p1.speed = p1.speed / p1.deceleration
        p1.speedUp = 0
    end

    if love.keyboard.isDown('s') then
        if p1.speed > -1 * (heatSettings.cc/50) then
            p1.speed = ((1 + p1.speed) / (p1.deceleration * 1.2)) - 1
        end
    end

    if love.keyboard.isDown('lshift') or heatSettings.mode == 1 then
        p1.drift = true
    else
        p1.drift = false
    end
    
    if p1.drift then
        p1.driftAmount = drift.sens
        p1.sprite = sprites.rb
    else
        --                    modify                ((difference) * half of a modifier)
        p1.driftAmount = p1.driftAmount - ((p1.driftAmount - drift.amount) * (0.5 * drift.sens))
        p1.sprite = sprites.r
    end

    -- update direction
    p1.x_vel = p1.x_vel - ((p1.x_vel - math.cos(((p1.angle)*pi)/180)) * p1.driftAmount)
    p1.y_vel = p1.y_vel - ((p1.y_vel - math.sin(((p1.angle)*pi)/180)) * p1.driftAmount)
    
    -- move player
    p1.x_pos = p1.x_pos + (p1.x_vel * p1.speed)
    p1.y_pos = p1.y_pos + (p1.y_vel * p1.speed)
end

-- DEBUG CONTROLLS --
function debugger()
    if love.keyboard.isDown('r') then
        p1.x_pos = 100
        p1.y_pos = 100
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
    cam:lookAt(p1.x_pos,p1.y_pos)

    time.lap = time.lap + upElapsed
    if p1.on == 0 then
        time.out = time.out + upElapsed
        timeOutAlpha = 1
    else
        timeOutAlpha = 0
    end

    -- laps --
    if p1.on == 0.2 then
        if p1.check < gameSettings.track.checkScore and p1.check > 2 * gameSettings.track.checkScore then
            time.out = time.out * 2
        end
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
            gameSettings.scene = 4
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

        p1.check = 0
    end

    -- checkpoints --
    if p1.on*255 == 52 then
        p1.check = 1
    end
    if p1.on*255 == 53 then
        if p1.check == 1 then
            p1.check = 2
        end
    end
    if p1.on*255 == 54 then
        if p1.check == 2 then
            p1.check = 3
        end
    end
    if p1.on*255 == 55 then
        if p1.check == 3 then
            p1.check = 4
        end
    end
    if p1.on*255 == 56 then
        if p1.check == 4 then
            p1.check = 5
        end
    end
    if p1.on*255 == 57 then
        if p1.check == 5 then
            p1.check = 6
        end
    end
    if p1.on*255 == 58 then
        p1.check = 7
    end
    if p1.on*255 == 59 then
        p1.check = 8
    end
    if p1.on*255 == 60 then
        p1.check = 9
    end
    if p1.on*255 == 61 then
        p1.check = 10
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
        cam:rotateTo(-((p1.angle+90)*pi)/180)
    end
end

-- DRAWS EVERY FRAME --
function love.draw()
    p1.on = gameSettings.track.trackData:getPixel(p1.x_pos + 2000,p1.y_pos + 2000)
    local vw = love.graphics.getWidth()
    local vh = love.graphics.getHeight()

    
    cam:attach()
    -- bg --
    love.graphics.draw(sprites.grid,sprites.gridQuad,-2000,-2000,0,1,1)
    if gameSettings.scene == 0 then
        love.graphics.print("Press space to play",-200,10,0,2,2)
    end
    if gameSettings.scene == 2 then
        love.graphics.draw(gameSettings.track.image,-2000,-2000,0,1,1) 

        -- player 1 --
        love.graphics.draw(
            p1.sprite,
            p1.x_pos,
            p1.y_pos,
            ((p1.angle-90)*pi)/180,
            p1.size/100,
            p1.size/100,
            p1.sprite:getWidth()/2,
            p1.sprite:getHeight()/2
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
        love.graphics.print("x_vel: "..p1.x_vel,100,20)
        love.graphics.print("y_vel: "..p1.y_vel,100,40)
        love.graphics.print("x_pos: "..p1.x_pos,100,60)
        love.graphics.print("y_pos: "..p1.y_pos,100,80)
        love.graphics.print("angle: "..p1.angle,100,100)
        love.graphics.print("speed: "..p1.speed,100,120)
        love.graphics.print("drift: "..tostring(p1.drift),100,140)
        love.graphics.print("driftAmount: "..p1.driftAmount,100,160)
        love.graphics.print("scene: "..gameSettings.scene,100,180)
        love.graphics.print("pixel: "..p1.on,100,200)
        love.graphics.print("checkpoint score: "..p1.check.."/"..gameSettings.track.checkScore,100,220)
    end
end