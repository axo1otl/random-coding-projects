function love.load()
    size = 20
    wk = {size = 0.1, alpha = 0}
    ak = {size = 0.1, alpha = 0}
    sk = {size = 0.1, alpha = 0}
    dk = {size = 0.1, alpha = 0}
    itr = 5

    board = {
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
        x = 200,y = 200
    }
    tile = {size = 50, buffer = 10}
    start = {x = math.random(4), y = math.random(4),x1 = math.random(4), y1 = math.random(4)}
end

--if love.keyboard.isDown('w','up') then
--        if wk.size >= size then
--            wk.size = size
--        end
--
--        wk.size = wk.size + itr
--
--        itr = itr / 1.1
--    else
--        wk.size = wk.size / 1.1
--        itr = 5
--    end

function love.update(dt)
    if love.keyboard.isDown('w','up') then
        wk.alpha = 1
    else
        wk.alpha = wk.alpha / 1.2
    end

    if love.keyboard.isDown('a','left') then
        ak.alpha = 1
    else
        ak.alpha = ak.alpha / 1.2
    end

    if love.keyboard.isDown('s','down') then
        sk.alpha = 1
    else
        sk.alpha = sk.alpha / 1.2
    end

    if love.keyboard.isDown('d','right') then
        dk.alpha = 1
    else
        dk.alpha = dk.alpha / 1.2
    end


end

function love.draw()
    -- love.graphics.rectangle("fill",110 - (wk.size / 2),110 - (wk.size / 2),wk.size,wk.size)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",100,100,size,size)
    love.graphics.setColor(1,1,1,wk.alpha)
    love.graphics.rectangle("fill",100,100,size,size)

    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",70,130,size,size)
    love.graphics.setColor(1,1,1,ak.alpha)
    love.graphics.rectangle("fill",70,130,size,size)

    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",100,130,size,size)
    love.graphics.setColor(1,1,1,sk.alpha)
    love.graphics.rectangle("fill",100,130,size,size)

    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line",130,130,size,size)
    love.graphics.setColor(1,1,1,dk.alpha)
    love.graphics.rectangle("fill",130,130,size,size)


-- board drawing
    love.graphics.setColor(0.4,0.4,0.4,1)
    love.graphics.rectangle("fill",board.x,board.y,(tile.buffer * 5) + (tile.size * 4),(tile.buffer * 5) + (tile.size * 4))

    love.graphics.setColor(0.5,0.5,0.5,1)

    love.graphics.rectangle("fill",(board.x + tile.buffer),(board.y + tile.buffer),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 2) + tile.size),(board.y + tile.buffer),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 3) + (tile.size * 2)),(board.y + tile.buffer),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 4) + (tile.size * 3)),(board.y + tile.buffer),tile.size,tile.size)

    love.graphics.rectangle("fill",(board.x + tile.buffer),(board.x + (tile.buffer * 2) + tile.size),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 2) + tile.size),(board.x + (tile.buffer * 2) + tile.size),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 3) + (tile.size * 2)),(board.x + (tile.buffer * 2) + tile.size),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 4) + (tile.size * 3)),(board.x + (tile.buffer * 2) + tile.size),tile.size,tile.size)

    love.graphics.rectangle("fill",(board.x + tile.buffer),(board.x + (tile.buffer * 3) + (tile.size * 2)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 2) + tile.size),(board.x + (tile.buffer * 3) + (tile.size * 2)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 3) + (tile.size * 2)),(board.x + (tile.buffer * 3) + (tile.size * 2)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 4) + (tile.size * 3)),(board.x + (tile.buffer * 3) + (tile.size * 2)),tile.size,tile.size)

    love.graphics.rectangle("fill",(board.x + tile.buffer),(board.x + (tile.buffer * 4) + (tile.size * 3)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 2) + tile.size),(board.x + (tile.buffer * 4) + (tile.size * 3)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 3) + (tile.size * 2)),(board.x + (tile.buffer * 4) + (tile.size * 3)),tile.size,tile.size)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * 4) + (tile.size * 3)),(board.x + (tile.buffer * 4) + (tile.size * 3)),tile.size,tile.size)

    -- Starting tiles
    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * start.x) + (tile.size * (start.x - 1))),(board.y + (tile.buffer * start.y) + (tile.size * (start.y - 1))),tile.size,tile.size)
    
    love.graphics.setColor(0,0,1,1)
    love.graphics.rectangle("fill",(board.x + (tile.buffer * start.x1) + (tile.size * (start.x1 - 1))),(board.y + (tile.buffer * start.y1) + (tile.size * (start.y1 - 1))),tile.size,tile.size)

end