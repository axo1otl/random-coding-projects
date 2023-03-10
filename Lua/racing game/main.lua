debug = false

local moonshine = require 'moonshine'

function love.load() 
    love.window.setFullscreen(true)
    cam = require "camera"
    cam = cam.new(0,0,0.75,0,damped)
    null = {}
    warning = ""

    vw = love.graphics.getWidth()
    vh = love.graphics.getHeight()
    
    camera = {
        zoom = 1,
        rotate = false,
        buffer = null
    }

    tracks = {
        test = {
            startPos = {
                x = -480,
                y = -1380,
                buffer = null
            },
            image = love.graphics.newImage("maps/test track.png"),
            trackData = love.image.newImageData("maps/test track.png"),
            checkScore = 0,
            buffer = null
        },
        tight = {
            name = "tight corners",
            startPos = {
                x = -550,
                y = -1250,
            buffer = null
            },
            image = love.graphics.newImage("maps/test 2.png"),
            trackData = love.image.newImageData("maps/test 2.png"),
            checkScore = 5,
            buffer = null
        },
        drift = {
            name = "drift city",
            startPos = {
                x = -550,
                y = -1250,
            buffer = null
            },
            image = love.graphics.newImage("maps/drift.png"),
            trackData = love.image.newImageData("maps/drift.png"),
            checkScore = 0,
            buffer = null
        },
        overlap = { -- still gotta change the start pos + add checkpoints + track change triggers
            name = "overlap",
            startPos = {
                x = -550,
                y = -1250,
            buffer = null
            },
            image = love.graphics.newImage("maps/overlap1.png"),
            trackData = love.image.newImageData("maps/overlap1.png"),
            image2 = love.graphics.newImage("maps/overlap2.png"),
            trackData2 = love.image.newImageData("maps/overlap2.png"),
            checkScore = 0,
            buffer = null
        },
        buffer = null
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
        buffer = null
    }

    heatSettings = {
        cc = 200, -- 100 144hz 200 60hz
        map = tracks.overlap,
        ai = false,
        mode = 1, -- 0: normal | 1: drift | 2: ???
        buffer = null
    }

    gameSettings = {
        scene = 0,  -- 0: menu | 1: pre-game | 2: game | 3: post-game | 4: pause | 5: settings
                    -- 6: in-game settings
        buffer = null
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
        on = heatSettings.map.trackData:getPixel(2000,2000),
        check = 0,
        
        -- static vars
        size = 20,
        acceleration = 1.1,
        deceleration = 1.02,
        turnSens = 2, -- 1.5 144hz | 2 60hz
        load = true,
        sprite = {
            a = 0,
            n = sprites.y,
            b = sprites.yb,
            buffer = null
        },
        buffer = null
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
            l5 = 0
        },
        buffer = null,
    }

    select = {
        pos = {
            x = 5,
            y = 60,
            buffer = null
        },
        alpha = 1,
        buffer = null
    }

    settingsMenu = {
    -- this works by ints (0,1,2...) when the menu screen is loaded, these settings 
    -- will apply navigate through the settings with 'w' and 's' keys and an 
    -- "active" modifier for 'a' and 'd' keys
        camera = {
            zoom = 2,
            rotate = 0,
            buffer = null
        },
        shaders = {
            chromasep = 1,
            crt = 0,
            filmgrain = 0,
            glow = 1,
            pixelate = 0,
            scanlines = 1,
            sketch = 0,
            vignette = 0,
            buffer = null
        },
        heat = {
            cc = heatSettings.cc,
            spriteN = p1.sprite.n,
            spriteB = p1.sprite.b,
            mode = 0,
            buffer = null
        },
        handling = {
            turnSens = p1.turnSens,
            seeVels = 0,
            buffer = null
        },
        buffer = null
    }

    
    
    sprites.grid:setWrap("repeat","repeat")
    pi = 3.14159265359
    fps = 0
    upSpeed = 0.1 -- how often the fps updates
    upElapsed = 0 -- will be added onto until larger than upSpeed and resets
    test = 0
    newLap = false
    shader = moonshine(moonshine.effects.colorgradesimple)
    shaderLoad = false

    Czoom = {0,1,0,1}
    Crot = {1,1,1,1}
    Cca = {0,1,0,1}
    Ccrt = {1,1,1,1}
    Cfg = {1,1,1,1}
    Cblm = {0,1,0,1}
    Cpxl = {1,1,1,1}
    Cscln = {0,1,0,1}
    Cskch = {1,1,1,1}
    Cv = {1,1,1,1}
    Cdom = {0,1,0,1}
    Csvv = {1,1,1,1}
end

-- CONTROLLING THE PLAYERS --
function control()
    if p1.load then
        p1.x_pos = heatSettings.map.startPos.x
        p1.y_pos = heatSettings.map.startPos.y
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
        p1.sprite.a = p1.sprite.b
    else
        --                    modify                ((difference) * half of a modifier)
        p1.driftAmount = p1.driftAmount - ((p1.driftAmount - drift.amount) * (0.5 * drift.sens))
        p1.sprite.a = p1.sprite.n
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

-- SHADERS --
function loadShaders()
    shader = moonshine(moonshine.effects.colorgradesimple)
    if settingsMenu.shaders.chromasep == 1 then shader = shader.chain(moonshine.effects.chromasep) 
        shader.chromasep.angle = 0
        shader.chromasep.radius = 2
    end
    if settingsMenu.shaders.pixelate == 1 then shader = shader.chain(moonshine.effects.pixelate) 
        shader.pixelate.size = 4
    end
    if settingsMenu.shaders.scanlines == 1 then shader = shader.chain(moonshine.effects.scanlines) 
        shader.scanlines.opacity = 0.5
    end
    if settingsMenu.shaders.crt == 1 then shader = shader.chain(moonshine.effects.crt) end
    if settingsMenu.shaders.filmgrain == 1 then shader = shader.chain(moonshine.effects.filmgrain) 
        shader.filmgrain.size = 2
        shader.filmgrain.opacity = 1
    end
    if settingsMenu.shaders.glow == 1 then shader = shader.chain(moonshine.effects.glow) 
        shader.glow.min_luma = 0.5
        shader.glow.strength = 5
    end
    if settingsMenu.shaders.sketch == 1 then shader = shader.chain(moonshine.effects.sketch) end
    if settingsMenu.shaders.vignette == 1 then shader = shader.chain(moonshine.effects.vignette) end
end

-- NAVIGATION STUFF --
function menu()
    cam:lookAt(100,100)
    cam:zoomTo(settingsMenu.camera.zoom)
    if love.keyboard.isDown('space') then
        gameSettings.scene = 1
    end

    if shaderLoad == false then
        loadShaders()
        shaderLoad = true
    end
end

function preGame()
    gameSettings.scene = 2
end
function postGame()
    
end
function settings()
    if from == 4 then
        gameSettings.scene = 6
    end
    -- settings 
end

function game()
    cam:lookAt(p1.x_pos,p1.y_pos)

    paused = false

    time.lap = time.lap + upElapsed
    if p1.on == 0 then
        time.out = time.out + upElapsed
        timeOutAlpha = 1
    else
        timeOutAlpha = 0
    end

    -- laps --
    if p1.on == 0.2 then
        if not p1.check == heatSettings.map.trackData then
            warning = "Missed "..(heatSettings.map.trackData - p1.check).." checkpoints"
        else
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
                gameSettings.scene = 3
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
        if p1.check == 6 then
            p1.check = 7
        end
    end
    if p1.on*255 == 59 then
        if p1.check == 7 then
            p1.check = 8
        end
    end
    if p1.on*255 == 60 then
        if p1.check == 8 then
            p1.check = 9
        end
    end
    if p1.on*255 == 61 then
        if p1.check == 9 then
            p1.check = 10
        end
    end
    if p1.on*255 == 62 then
        if p1.check == 10 then
            p1.check = 11
        end
    end
    if p1.on*255 == 63 then
        if p1.check == 11 then
            p1.check = 12
        end
    end
    if p1.on*255 == 64 then
        if p1.check == 12 then
            p1.check = 13
        end
    end
    if p1.on*255 == 65 then
        if p1.check == 13 then
            p1.check = 14
        end
    end
    if p1.on*255 == 66 then
        if p1.check == 14 then
            p1.check = 15
        end
    end
    if p1.on*255 == 67 then
        if p1.check == 15 then
            p1.check = 16
        end
    end

end

function pause()
    paused = true
    select.pos.x = 10
    --select.pos.y = 60
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        if gameSettings.scene == 0 then -- if in menu
            love.event.quit()           -- quit game
        end
        if gameSettings.scene == 5 then -- if in settings
            gameSettings.scene = 2      -- go to menu
        end
        if gameSettings.scene == 4 then -- if paused
            gameSettings.scene = 40      -- go to pause2
        end
        if gameSettings.scene == 2 then -- if in game
            gameSettings.scene = 4      -- pause
        end
        if gameSettings.scene == 1 then -- if in pre-game
            gameSettings.scene = 0      -- go to menu
        end
        if gameSettings.scene == 3 then -- if in post-game
            gameSettings.scene = 0      -- go to menu
        end
        if gameSettings.scene == 40 then -- if paused2
            gameSettings.scene = 2      -- go to game
        end
    end

    if paused and (key == "down" or key == 's') then
        if pauseMenuLoad then
            select.pos.y = 60
            pauseMenuLoad = false
        end

        if select.pos.y == 100 then
            select.pos.y = 120
        end
        if select.pos.y == 80 then
            select.pos.y = 100
        end
        if select.pos.y == 60 then
            select.pos.y = 80
        end
        if select.pos.y == 120 then
            select.pos.y = 60
        end
    end
    if paused and (key == "up" or key == 'w') then
        if pauseMenuLoad then
            select.pos.y = 60
            pauseMenuLoad = false
        end
        if select.pos.y == 60 then
            select.pos.y = 120
        end
        if select.pos.y == 80 then
            select.pos.y = 60
        end
        if select.pos.y == 100 then
            select.pos.y = 80
        end
        if select.pos.y == 120 then
            select.pos.y = 100
        end
    end

    if paused and (key == "return" or key == "space") then
        if select.pos.y == 60 then
            paused = false
            pauseMenuLoad = true
            gameSettings.scene = 2
        end
        if select.pos.y == 80 then
            paused = false
            pauseMenuLoad = true
            select.pos.y = 60
            gameSettings.scene = 5
            from = 4
        end
        if select.pos.y == 100 or select.pos.y == 120 then
            paused = false
            pauseMenuLoad = true
            settingsLoad = true
            gameSettings.scene = 0
        end
    end

    if gameSettings.scene == 5 and (key == "down" or key == 's') then
        if settingsLoad then
            select.pos.y = 80
            settingsLoad = false
        end
        if select.pos.y == 315 then select.pos.y = 3300 end
        if select.pos.y == 300 then select.pos.y = 315 end
        if select.pos.y == 245 then select.pos.y = 300 end
        if select.pos.y == 230 then select.pos.y = 245 end
        if select.pos.y == 215 then select.pos.y = 230 end
        if select.pos.y == 200 then select.pos.y = 215 end
        if select.pos.y == 185 then select.pos.y = 200 end
        if select.pos.y == 170 then select.pos.y = 185 end
        if select.pos.y == 155 then select.pos.y = 170 end
        if select.pos.y == 140 then select.pos.y = 155 end
        if select.pos.y == 95 then select.pos.y = 140 end
        if select.pos.y == 80 then select.pos.y = 95 end
        if select.pos.y == 60 then select.pos.y = 80 end
        if select.pos.y == 3300 then select.pos.y = 60 end
    end
    if gameSettings.scene == 5 and (key == "up" or key == 'w') then
        if settingsLoad then
            select.pos.y = 80
            settingsLoad = false
        end

        if select.pos.y == 80 then select.pos.y = 3300 end
        if select.pos.y == 95 then select.pos.y = 80 end
        if select.pos.y == 140 then select.pos.y = 95 end
        if select.pos.y == 155 then select.pos.y = 140 end
        if select.pos.y == 170 then select.pos.y = 155 end
        if select.pos.y == 185 then select.pos.y = 170 end
        if select.pos.y == 200 then select.pos.y = 185 end
        if select.pos.y == 215 then select.pos.y = 200 end
        if select.pos.y == 230 then select.pos.y = 215 end
        if select.pos.y == 245 then select.pos.y = 230 end
        if select.pos.y == 300 then select.pos.y = 245 end
        if select.pos.y == 315 then select.pos.y = 300 end
        if select.pos.y == 3300 then select.pos.y = 315 end
    end
    if gameSettings.scene == 5 and key == "return" or key == 'a' or key == 'd' then
        if select.pos.y == 80 then 
            if settingsMenu.camera.zoom == 2 then
                settingsMenu.camera.zoom = 4
                Czoom = {1,1,1,1}
            end
            if settingsMenu.camera.zoom == 1 then
                settingsMenu.camera.zoom = 2
                Czoom = {0,1,0,1}
            end
            if settingsMenu.camera.zoom == 4 then
                settingsMenu.camera.zoom = 1
            end
        end
        if select.pos.y == 95 then 
            if settingsMenu.camera.rotate == 1 then
                settingsMenu.camera.rotate = 2
                Crot = {1,1,1,1}
            end
            if settingsMenu.camera.rotate == 0 then
                settingsMenu.camera.rotate = 1
                Crot = {0,1,0,1}
            end
            if settingsMenu.camera.rotate == 2 then
                settingsMenu.camera.rotate = 0
            end
        end
        if select.pos.y == 140 then 
            if settingsMenu.shaders.chromasep == 1 then
                settingsMenu.shaders.chromasep = 2
                Cca = {1,1,1,1}
            end
            if settingsMenu.shaders.chromasep == 0 then
                settingsMenu.shaders.chromasep = 1
                Cca = {0,1,0,1}
            end
            if settingsMenu.shaders.chromasep == 2 then
                settingsMenu.shaders.chromasep = 0
            end
            loadShaders()
        end
        if select.pos.y == 155 then 
            if settingsMenu.shaders.crt == 1 then
                settingsMenu.shaders.crt = 2
                Ccrt = {1,1,1,1}
            end
            if settingsMenu.shaders.crt == 0 then
                settingsMenu.shaders.crt = 1
                Ccrt = {0,1,0,1}
            end
            if settingsMenu.shaders.crt == 2 then
                settingsMenu.shaders.crt = 0
            end
            loadShaders()
        end
        if select.pos.y == 170 then 
            if settingsMenu.shaders.filmgrain == 1 then
                settingsMenu.shaders.filmgrain = 2
                Cfg = {1,1,1,1}
            end
            if settingsMenu.shaders.filmgrain == 0 then
                settingsMenu.shaders.filmgrain = 1
                Cfg = {0,1,0,1}
            end
            if settingsMenu.shaders.filmgrain == 2 then
                settingsMenu.shaders.filmgrain = 0
            end
            loadShaders()
        end
        if select.pos.y == 185 then 
            if settingsMenu.shaders.glow == 1 then
                settingsMenu.shaders.glow = 2
                Cblm = {1,1,1,1}
            end
            if settingsMenu.shaders.glow == 0 then
                settingsMenu.shaders.glow = 1
                Cblm = {0,1,0,1}
            end
            if settingsMenu.shaders.glow == 2 then
                settingsMenu.shaders.glow = 0
            end
            loadShaders()
        end
        if select.pos.y == 200 then 
            if settingsMenu.shaders.pixelate == 1 then
                settingsMenu.shaders.pixelate = 2
                Cpxl = {1,1,1,1}
            end
            if settingsMenu.shaders.pixelate == 0 then
                settingsMenu.shaders.pixelate = 1
                Cpxl = {0,1,0,1}
            end
            if settingsMenu.shaders.pixelate == 2 then
                settingsMenu.shaders.pixelate = 0
            end
            loadShaders()
        end
        if select.pos.y == 215 then 
            if settingsMenu.shaders.scanlines == 1 then
                settingsMenu.shaders.scanlines = 2
                Cslcn = {1,1,1,1}
            end
            if settingsMenu.shaders.scanlines == 0 then
                settingsMenu.shaders.scanlines = 1
                Cscln = {0,1,0,1}
            end
            if settingsMenu.shaders.scanlines == 2 then
                settingsMenu.shaders.scanlines = 0
            end
            loadShaders()
        end
        if select.pos.y == 230 then 
            if settingsMenu.shaders.sketch == 1 then
                settingsMenu.shaders.sketch = 2
                Cskch = {1,1,1,1}
            end
            if settingsMenu.shaders.sketch == 0 then
                settingsMenu.shaders.sketch = 1
                Cskch = {0,1,0,1}
            end
            if settingsMenu.shaders.sketch == 2 then
                settingsMenu.shaders.sketch = 0
            end
            loadShaders()
        end
        if select.pos.y == 245 then 
            if settingsMenu.shaders.vignette == 1 then
                settingsMenu.shaders.vignette = 2
                Cv = {1,1,1,1}
            end
            if settingsMenu.shaders.vignette == 0 then
                settingsMenu.shaders.vignette = 1
                Cv = {0,1,0,1}
            end
            if settingsMenu.shaders.vignette == 2 then
                settingsMenu.shaders.vignette = 0
            end 
            loadShaders()
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
    if gameSettings.scene == 1 then
        preGame()
    end
    if gameSettings.scene == 2 then
        control()
        game()
    end
    if gameSettings.scene == 3 then
        postGame()
    end
    if gameSettings.scene == 4 then
        pause()
    end
    if gameSettings == 5 then
        settings()
    end
    debugger()
    cam:zoomTo(settingsMenu.camera.zoom)
    if settingsMenu.camera.rotate == 1 then
        cam:rotateTo(-((p1.angle+90)*pi)/180)
    else
        cam:rotateTo(0)
    end
end

-- DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME --
-- DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME DRAWS EVERY FRAME --
function love.draw()
    shader(function()
        love.graphics.setDefaultFilter("nearest")
        p1.on = heatSettings.map.trackData:getPixel(p1.x_pos + 2000,p1.y_pos + 2000)
        
        cam:attach()
            -- bg --
            love.graphics.draw(sprites.grid,sprites.gridQuad,-2000,-2000,0,1,1)
            if gameSettings.scene == 2 or gameSettings.scene == 4 then
                love.graphics.draw(heatSettings.map.image,-2000,-2000,0,1,1) 

                -- player 1 --
                love.graphics.draw(
                    p1.sprite.a,
                    p1.x_pos,
                    p1.y_pos,
                ((p1.angle-90)*pi)/180,
                p1.size/100,
                p1.size/100,
                p1.sprite.a:getWidth()/2,
                p1.sprite.a:getHeight()/2
                )
                if settingsMenu.handling.seeVels == 1 then
                    love.graphics.setColor(1,0,0,1)
                    love.graphics.rectangle("fill",p1.x_pos,p1.y_pos,p1.x_vel*100,2)
                    love.graphics.setColor(0,0,1,1)
                    love.graphics.rectangle("fill",p1.x_pos,p1.y_pos,2,p1.y_vel*100)
                end
            end
        cam:detach()
        
        if gameSettings.scene == 0 then
            love.graphics.print("smat racr",20,20,0,5,5)
        end
    end)

    -- timers --
    if gameSettings.scene == 2 then
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
    end

    love.graphics.print("FPS: "..fps,0,0)

    if debug then
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
        love.graphics.print("checkpoint score: "..p1.check.."/"..heatSettings.map.checkScore,100,220)
        love.graphics.print("select y: "..select.pos.y,100,240)
        love.graphics.print("camera zoom: "..settingsMenu.camera.zoom,100,260)
    end

    -- pausing --
    if gameSettings.scene == 4 then
        love.graphics.setColor(0,0,0,0.75)
        love.graphics.rectangle("fill",0,0,vw,vh)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print("Paused",20,20,0,2,2)
        love.graphics.print("back to game",20,60,0,1,1)
        love.graphics.print("settings",20,80,0,1,1)
        love.graphics.print("quit",20,100,0,1,1)
        love.graphics.print("|",select.pos.x,select.pos.y,0,1,1)
    end

    if gameSettings.scene == 5 then
        local hAlpha = 0.5
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill",0,0,vw,vh)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print("Settings",20,20,0,2,2)

        love.graphics.setColor(1,1,1,hAlpha)
        love.graphics.print("Camera",20,60,0,1.5,1.5)
        
        love.graphics.setColor(Czoom)
        love.graphics.print("zoom",20,80,0,1,1)
        love.graphics.setColor(Crot)
        love.graphics.print("rotate with player",20,95,0,1,1)
        
        love.graphics.setColor(1,1,1,hAlpha)
        love.graphics.print("Shaders",20,120,0,1.5,1.5)
        love.graphics.setColor(1,1,1,1)
        
        love.graphics.setColor(Cca)
        love.graphics.print("chromatic abberation",20,140,0,1,1)
        love.graphics.setColor(Ccrt)
        love.graphics.print("crt",20,155,0,1,1)
        love.graphics.setColor(Cfg)
        love.graphics.print("film grain",20,170,0,1,1)
        love.graphics.setColor(Cblm)
        love.graphics.print("bloom",20,185,0,1,1)
        love.graphics.setColor(Cpxl)
        love.graphics.print("pixelate",20,200,0,1,1)
        love.graphics.setColor(Cscln)
        love.graphics.print("scanlines",20,215,0,1,1)
        love.graphics.setColor(Cskch)
        love.graphics.print("sketch",20,230,0,1,1)
        love.graphics.setColor(Cv)
        love.graphics.print("vignette",20,245,0,1,1)

        love.graphics.setColor(1,1,1,1)
        love.graphics.print("|",select.pos.x,select.pos.y,0,1,1)
    end
end