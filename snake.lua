local Snake = {}

function Snake:new(x, y)
    -- Generate vibrant pastel colors by mixing full saturation with white
    local baseR, baseG, baseB = math.random(), math.random(), math.random()
    local whiteMix = 0.25  -- Amount of white to mix in
    
    local snake = {
        x = x,
        y = y,
        angle = math.random() * math.pi * 2,
        turnSpeed = math.random() * 2 - 1,
        baseSpeed = 350,    -- Initial faster speed
        minSpeed = 50,      -- Minimum speed when grown
        speed = 350,        -- Current speed
        segments = {{x = x, y = y}},
        length = 10,
        matureAge = math.random(40, 250),  -- Random maturity threshold
        color = {
            baseR * (1 - whiteMix) + whiteMix,  -- Mix with white
            baseG * (1 - whiteMix) + whiteMix,
            baseB * (1 - whiteMix) + whiteMix
        },
        senseRadius = 128,  -- How far the snake can sense food
        maxTurnSpeed = math.random(3, 6)    -- Maximum turning rate
    }
    setmetatable(snake, {__index = self})
    return snake
end

function Snake:findNearestFood(foodList)
    local nearestDist = self.senseRadius * self.senseRadius
    local nearest = nil
    
    for _, food in ipairs(foodList) do
        local dx = (food.x - self.x)
        local dy = (food.y - self.y)
        local dist = dx * dx + dy * dy
        if dist < nearestDist then
            nearestDist = dist
            nearest = food
        end
    end
    
    return nearest
end

function Snake:update(dt, width, height, foodList)
    -- Find nearest food and adjust turn speed
    local target = self:findNearestFood(foodList)
    if target then
        -- Calculate angle to food
        local dx = target.x - self.x
        local dy = target.y - self.y
        local targetAngle = math.atan2(dy, dx)
        
        -- Calculate angle difference
        local angleDiff = (targetAngle - self.angle)
        if angleDiff > math.pi then
            angleDiff = angleDiff - 2 * math.pi
        elseif angleDiff < -math.pi then
            angleDiff = angleDiff + 2 * math.pi
        end
        
        -- Adjust turn speed based on angle to food
        self.turnSpeed = math.max(-self.maxTurnSpeed, 
                                math.min(self.maxTurnSpeed, angleDiff * 2))
    else
        -- Random wandering when no food is nearby
        self.turnSpeed = math.random() * 2 - 1
    end
    
    -- Update angle
    self.angle = self.angle + self.turnSpeed * dt
    
    -- Move head
    local dx = math.cos(self.angle) * self.speed * dt
    local dy = math.sin(self.angle) * self.speed * dt
    
    self.x = (self.x + dx) % width
    self.y = (self.y + dy) % height
    
    -- Add new segment
    table.insert(self.segments, 1, {x = self.x, y = self.y})
    
    -- Remove excess segments
    while #self.segments > self.length do
        table.remove(self.segments)
    end
end

function Snake:updateSpeed()
    -- Calculate speed based on length
    -- Speed decreases as length increases, but never below minSpeed
    self.speed = math.max(
        self.minSpeed,
        self.baseSpeed * (20 / math.max(20, self.length))
    )
end

function Snake:draw()
    -- Draw glow layers
    for layer = 3, 1, -1 do
        local alpha = 0.2 / layer
        local size = 4 + (layer * 2)
        
        love.graphics.setColor(
            self.color[1],
            self.color[2],
            self.color[3],
            alpha
        )
        
        for _, segment in ipairs(self.segments) do
            love.graphics.circle("fill", segment.x, segment.y, size)
        end
    end
    
    -- Draw solid snake body on top
    love.graphics.setColor(
        math.min(1.2 * self.color[1], 1),
        math.min(1.2 * self.color[2], 1),
        math.min(1.2 * self.color[3], 1),
        1
    )
    for _, segment in ipairs(self.segments) do
        love.graphics.circle("fill", segment.x, segment.y, 4)
    end
end

function Snake:checkFood(food, radius)
    local dx = self.x - food.x
    local dy = self.y - food.y
    if dx * dx + dy * dy < radius * radius then
        self.length = self.length + 5
        self:updateSpeed()  -- Update speed when growing
        return true
    end
    return false
end

return Snake
