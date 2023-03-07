function love.load()
    player = {
    x_vel = 0,
    y_vel = 0,
    x_pos = 0,
    y_pos = 0,
    size = 20,
    speed = 5,
    jumpPower = 15, -- 15
    }

    levelNum = 1

    --window = {
    --    width = love.graphics.getWidth(),
    --    height = love.graphics.getHeight()
    --}

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    
    i = 1
    phys_x = 1
    start = true
    onSegment = false
end

function level(levelNum, input,x,y)
    lvl = {
        floor = {
            500 + player.size,
            200 + player.size,
        },
        segment = {
            {--  X             length        Y
                {0           , (width/6)*1 , 450},
                {(width/6)*1 , (width/6)*1 , 400},
                {(width/6)*2 , (width/6)*1 , 350},
                {(width/6)*3 , (width/6)*1 , 300},
                {(width/6)*4 , (width/6)*1 , 250},
                {(width/6)*5 , (width/6)*1 , 200},
            },
        },
        numOfSegments = {
            6,
            6,
        }

    }

    if input == "floor" then
        return(lvl.floor[levelNum])
    end
    if input == "segment" then
        return(lvl.segment[levelNum][x][y])
    end
    if input == "numOfsegments" then
        return(lvl.numOfSegments[levelNum])
    end
end

function love.keypressed(key,scancode)
    if (scancode == "escape") then
        love.event.quit()
    end

    if (scancode == "w") then
        if (player.y_vel <= 0.2) and (player.y_vel >= -0.2) then
            player.y_vel = player.y_vel - player.jumpPower
        end
    end
end

function physics(levelNum , scancode)
    -- Ground Physics --
    -- TRY TO INTEGRATE GEOMETRY INTO THIS SO ITS NOT LOCKED TO JUST THE GROUND --
    --if (player.y_pos + player.y_vel) < level(levelNum,"floor") - player.size then
    --    player.y_vel = player.y_vel + 1.1
    --    player.y_pos = player.y_pos + player.y_vel
    --else
    --    player.y_vel = 0
    --    player.y_pos = level(levelNum,"floor") - player.size
    --end

    -- moving left and right --
    if love.keyboard.isDown("a") then
        player.x_vel = -player.speed

    elseif love.keyboard.isDown("d") then
        player.x_vel = player.speed

    else
        player.x_vel = 0
    end

    if player.x_pos + player.x_vel < 0 then
        player.x_pos = 0
        player.x_vel = 0

    elseif player.x_pos + player.x_vel > love.graphics.getWidth() - player.size then
        player.x_pos = love.graphics.getWidth() - player.size
        player.x_vel = 0
    end

    -- Determins the x and y stop for segments of level --
    if player.x_pos > 0 and player.x_pos < level(levelNum,"segment",1,1) + level(levelNum,"segment",1,2) then
        phys_x = 1
    end
    if player.x_pos > level(levelNum,"segment",2,1) + level(levelNum,"segment",1,2) then
        phys_x = 2
    end
    if player.x_pos > level(levelNum,"segment",3,1) + level(levelNum,"segment",2,2) then
        phys_x = 3
    end
    if player.x_pos > level(levelNum,"segment",4,1) + level(levelNum,"segment",3,2) then
        phys_x = 4
    end
    if player.x_pos > level(levelNum,"segment",5,1) + level(levelNum,"segment",4,2) then
        phys_x = 5
    end
    if player.x_pos > level(levelNum,"segment",6,1) + level(levelNum,"segment",5,2) then
        phys_x = 6
    end

    -- y stop --
    -- check for current y above platform --
    if player.y_pos + player.y_vel < level(levelNum,"segment",phys_x,3) - player.size then
        player.y_vel = player.y_vel + 1.1
        player.y_pos = player.y_pos + player.y_vel
    else
        -- Jump -- 
        if love.keyboard.isDown("w") then
            if (player.y_vel <= 0.2) and (player.y_vel >= -0.2) then
                player.y_vel = -player.jumpPower
            end
        else
            player.y_vel = 0
            player.y_pos = level(levelNum,"segment",phys_x,3) + player.size
        end
    end

    -- x stop --
    -- check for y --
    if player.y_pos + player.y_vel > level(levelNum,"segment",phys_x,3) then
        -- check for x                   starting x                           ending x                             player size --
        if player.x_pos + player.x_vel > level(levelNum,"segment",phys_x,1) + level(levelNum,"segment",phys_x,2) - player.size then
            player.x_vel = 0
            player.x_pos = level(levelNum,"segment",phys_x,1) + level(levelNum,"segment",phys_x,2) - player.size
        end
    end

    player.x_pos = player.x_pos + player.x_vel
    
    if player.y_pos > love.graphics.getHeight() then
        love.event.quit()
    end
end

function startGame()
    if (player.y_pos + player.y_vel) < level(levelNum,"floor") - player.size then
        player.y_vel = player.y_vel + 1.1
        player.y_pos = player.y_pos + player.y_vel
    else
        player.y_vel = 0
        player.y_pos = level(levelNum,"floor") - player.size
        
        start = false
    end
end

function love.update()
    while start do
        startGame()
    end
    physics(levelNum)
end

function love.draw()

    -- player next frame --
    love.graphics.setColor(0,255,0)
    love.graphics.setLineWidth(1)
    love.graphics.print("kys",player.x_pos,player.y_pos)
    --love.graphics.rectangle(
    --    "line",
    --    (player.x_pos + player.x_vel),
    --    (player.y_pos + player.y_vel),
    --    player.size,
    --    player.size
    --)
    -- player --
    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(2)
    --love.graphics.print("kys",player.x_pos,player.y_pos)
    love.graphics.rectangle(
        "line",
        player.x_pos,
        player.y_pos,
        player.size,
        player.size
    )
    
    -- ground --
    love.graphics.setColor(255,255,255)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")
    love.graphics.rectangle("line",0,level(levelNum,"floor"),200,2)

    --while x < level(levelNum,"numOfSegments") do
        while i < 6 do
        love.graphics.rectangle(
            "fill",
            level(levelNum,"segment",i,1) + width/6,
            level(levelNum,"segment",i,3),
            level(levelNum,"segment",i,2),
            1000
        )
        i = i + 1
    end
    i = 1
    -- player vector up down --
    --love.graphics.setColor(255,0,0)
    --love.graphics.rectangle(
    --    "fill",
    --    player.x_pos + (player.size / 2),
    --    player.y_pos + (player.size / 2),
    --    2,
    --    player.y_vel*2
    --)
    ---- player vector left right --
    --love.graphics.setColor(0,0,255)
    --love.graphics.rectangle(
    --    "fill",
    --    player.x_pos + (player.size / 2),
    --    player.y_pos + (player.size / 2),
    --    player.x_vel*5,
    --    2
    --)
end