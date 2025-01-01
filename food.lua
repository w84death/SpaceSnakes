local Food = {}
Food.__index = Food

function Food:new(x, y)
    local food = {
        x = x,
        y = y
    }
    return setmetatable(food, Food)
end

function Food:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', self.x, self.y, 2)
end

return Food
