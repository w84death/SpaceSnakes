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

function Star:draw()
    local size = self.z * 1.25
    local brightness = 24 + 64 * (self.z * 0.5)
    love.graphics.setColor(brightness/255, brightness/255, brightness/255)
    love.graphics.circle('fill', self.x, self.y, size)
end

return Star
