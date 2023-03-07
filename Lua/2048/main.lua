function love.load()
    love.keyboard.setKeyRepeat(false)
    -- Creates board
    board = {
        {11,12,13,14},
        {21,22,23,24},
        {31,32,33,34},
        {41,42,43,44},
    }
    coord = {x = 1, y = 1}
end

function love.update()
    -- w key and up arrow key
    if love.keyboard.isDown('w') then
        if coord.y > 1 then
            coord.y = coord.y - 1
        end
        love.timer.sleep(0.1,s)
    end

    -- a key and left arrow key
    if love.keyboard.isDown('a','left') then
        if coord.x > 1 then
            coord.x = coord.x - 1
        end
        love.timer.sleep(0.1,s)
    end

    -- s key and down arrow key
    if love.keyboard.isDown('s','down') then
        if coord.y < 4 then
            coord.y = coord.y + 1
        end
        love.timer.sleep(0.1,s)
    end

    -- d key and right arrow key
    if love.keyboard.isDown('d','right') then
        if coord.x < 4 then
            coord.x = coord.x + 1
        end
        love.timer.sleep(0.1,s)
    end
end

function love.draw()
    font = love.graphics.getFont()
    text = love.graphics.newText(font,board[coord.x][coord.y])
    love.graphics.draw(text)
    love.graphics.rectangle("fill",coord.x*20,coord.y*20,20,20)
end