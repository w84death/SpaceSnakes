local World = require 'world'
local world

function love.load()
    love.window.setFullscreen(true)
    local width, height = love.window.getDesktopDimensions()
    world = World:new(width, height)
    
    -- Create initial snakes
    for i = 1, 10 do
        world:addSnake()
    end
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left click
        world:spawnFoodAt(x, y)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end
