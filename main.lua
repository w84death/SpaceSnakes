local World = require 'world'
local world

function love.load()
    love.window.setMode(800, 600)
    world = World:new(800, 600)
    
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
