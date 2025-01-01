local Snake = require 'snake'

-- Star class definition
local Star = {}
Star.__index = Star

function Star:new(width, height)
    local star = {
        x = love.math.random(0, width),
        y = love.math.random(0, height),
        z = love.math.random(0.1, 2),
        speed = 10,
    }
    return setmetatable(star, Star)
end

function Star:update(dt, width, height)
    self.y = self.y + self.speed * self.z * self.z * dt
    if self.y > height then
        self.y = 0
        self.x = love.math.random(0, width)
        self.z = love.math.random(0.1, 1.5)
    end
end

local World = {}

function World:new(width, height)
    local world = {
        width = width,
        height = height,
        snakes = {},
        food = {},
        foodSpawnTimer = 0,
        foodSpawnInterval = 1,
        stars = {}
    }
    
    -- Initialize stars
    for i = 1, 100 do
        table.insert(world.stars, Star:new(width, height))
    end

    setmetatable(world, {__index = self})
    return world
end

function World:addSnake()
    local snake = Snake:new(
        math.random(self.width),
        math.random(self.height)
    )
    table.insert(self.snakes, snake)
end

function World:spawnFoodAt(x, y)
    table.insert(self.food, {
        x = x,
        y = y
    })
end

function World:spawnFood()
    self:spawnFoodAt(
        math.random(self.width),
        math.random(self.height)
    )
end

function World:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star:update(dt, self.width, self.height)
    end

    -- Update snakes
    for _, snake in ipairs(self.snakes) do
        snake:update(dt, self.width, self.height, self.food)
    end
    
    -- Spawn food
    self.foodSpawnTimer = self.foodSpawnTimer + dt
    if self.foodSpawnTimer >= self.foodSpawnInterval then
        self:spawnFood()
        self.foodSpawnTimer = 0
    end
    
    -- Check food collision
    for i = #self.food, 1, -1 do
        for _, snake in ipairs(self.snakes) do
            if snake:checkFood(self.food[i], 5) then
                table.remove(self.food, i)
                break
            end
        end
    end
end

function World:draw()
    -- Draw stars
    for _, star in ipairs(self.stars) do
        local size = star.z
        local brightness = 12 + 128 * (star.z / 4)
        love.graphics.setColor(brightness/255, brightness/255, brightness/255)
        love.graphics.circle('fill', star.x, star.y, size)
    end
    
    -- Reset color for other elements
    love.graphics.setColor(1, 1, 1)

    -- Draw food
    love.graphics.setColor(1, 1, 0)
    for _, food in ipairs(self.food) do
        love.graphics.circle('fill', food.x, food.y, 2)
    end
    
    -- Draw snakes
    for _, snake in ipairs(self.snakes) do
        snake:draw()
    end
end

return World
