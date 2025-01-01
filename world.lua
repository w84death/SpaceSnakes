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
        particles = {},
        trailCanvas = love.graphics.newCanvas(width, height),
        waveTime = 0,       -- Global wave timer
        waveSpeed = 0.5,    -- Wave speed
        waveAmplitude = 15,  -- Wave size
        fadeTimer = 0,
        fadeInterval = 1,  -- Fade every 4 seconds
        fadeAlpha = 0.3    -- Fade intensity
    }
    
    -- Initialize trail canvas to white
    love.graphics.setCanvas(world.trailCanvas)
    love.graphics.clear(0, 0.05, 0.2, 1)
    love.graphics.setCanvas()
    
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

function World:handleReproduction()
    for i = #self.snakes, 1, -1 do
        if self.snakes[i].length > self.snakes[i].matureAge then
            -- Get position of parent snake before removing it
            local parentX = self.snakes[i].x
            local parentY = self.snakes[i].y
            
            -- Remove parent snake
            table.remove(self.snakes, i)
            
            -- Spawn two new snakes near parent's location
            for j = 1, 2 do
                local offset = 50  -- Spawn offset distance
                local newX = (parentX + math.random(-offset, offset)) % self.width
                local newY = (parentY + math.random(-offset, offset)) % self.height
                local snake = Snake:new(newX, newY)
                table.insert(self.snakes, snake)
            end
        end
    end
end

function World:update(dt)
    -- Update wave time
    self.waveTime = self.waveTime + dt * self.waveSpeed
    
    -- Update food positions based on wave
    for _, food in ipairs(self.food) do
        food:updatePosition(self.waveTime, self.waveAmplitude)
    end
    
    -- Update fade timer and apply fade effect
    self.fadeTimer = self.fadeTimer + dt
    if self.fadeTimer >= (1/15) then
        love.graphics.setCanvas(self.trailCanvas)
        love.graphics.setBlendMode('subtract', 'premultiplied')
        love.graphics.setColor(0.005, 0.005, 0.005, 1)
        love.graphics.rectangle('fill', 0, 0, self.width, self.height)
        love.graphics.setCanvas()
        self.fadeTimer = 0
    end
    
    -- Draw snake trails to canvas
    love.graphics.setCanvas(self.trailCanvas)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    
    for _, snake in ipairs(self.snakes) do
        -- Draw darker trail with slight transparency
        love.graphics.setColor(0.05, 0.25, 0.5, 0.001)
        -- Draw circle at the last segment position
        local lastSegment = snake.segments[#snake.segments]
        love.graphics.circle('fill', lastSegment.x, lastSegment.y, 3)
    end
    
    love.graphics.setCanvas()
    love.graphics.setBlendMode('alpha')
    
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
    
    -- Handle snake reproduction
    self:handleReproduction()
end

function World:draw()
    -- Set dark background first
    love.graphics.clear(0.06, 0.06, 0.08)
    
    -- Draw trail canvas with alpha blending
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.trailCanvas)
    
    -- Set additive blending for glowing effects
    love.graphics.setBlendMode('add', 'alphamultiply')
    
    -- Draw snakes with glow
    for _, snake in ipairs(self.snakes) do
        snake:draw()
    end
    
    -- Reset blend mode for UI elements
    love.graphics.setBlendMode('alpha')
    
    -- Draw food and particles
    for _, food in ipairs(self.food) do
        food:draw()
    end
    
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(1, 1, 1, p.alpha)
        love.graphics.circle('line', p.x, p.y, p.radius)
    end
end

return World
