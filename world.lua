local Snake = require 'snake'
local Food = require 'food'  -- Remove Star require

local World = {}

function World:new(width, height)
    local world = {
        width = width,
        height = height,
        snakes = {},
        food = {},
        foodSpawnTimer = 0,
        foodSpawnInterval = 1,
        particles = {}  -- Remove stars table
    }
    
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
    table.insert(self.food, Food:new(x, y))
end

function World:spawnFood()
    self:spawnFoodAt(
        math.random(self.width),
        math.random(self.height)
    )
end

function World:createFoodParticle(x, y)
    table.insert(self.particles, {
        x = x,
        y = y,
        radius = 5,
        alpha = 1,
        lifetime = 0.5,  -- Duration in seconds
        timer = 0
    })
end

function World:update(dt)
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
                -- Create particle effect when food is eaten
                self:createFoodParticle(self.food[i].x, self.food[i].y)
                table.remove(self.food, i)
                break
            end
        end
    end
    
    -- Update particles
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.timer = p.timer + dt
        p.radius = p.radius + (30 * dt)  -- Grow radius
        p.alpha = 1 - (p.timer / p.lifetime)  -- Fade out
        
        if p.timer >= p.lifetime then
            table.remove(self.particles, i)
        end
    end
end

function World:draw()
    -- Set dark background
    love.graphics.clear(0.06, 0.06, 0.08)
    
    -- Draw food
    for _, food in ipairs(self.food) do
        food:draw()
    end
    
    -- Draw particles
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(1, 1, 1, p.alpha)
        love.graphics.circle('line', p.x, p.y, p.radius)
    end
    
    -- Draw snakes
    for _, snake in ipairs(self.snakes) do
        snake:draw()
    end
end

return World
