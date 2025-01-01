local Food = {}
Food.__index = Food

function Food:new(x, y)
    local food = {
        x = x,
        y = y,
        initialX = x,  -- Store initial position
        initialY = y,
        phase = math.random() * math.pi * 2  -- Random starting phase
    }
    return setmetatable(food, Food)
end

function Food:updatePosition(time, amplitude)
    -- Create circular-ish motion using offset sine waves
    self.x = self.initialX + math.sin(time + self.phase) * amplitude
    self.y = self.initialY + math.cos(time * 1.3 + self.phase) * amplitude
end

function Food:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 2)
end

return Food
