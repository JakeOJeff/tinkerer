local cutscene = {}

function cutscene:init()
    self.active = false
    self.posX = 0
    self.posY = 0
    self.elapsed = 0
    self.time = 0
    self.startX = 0
    self.startY = 0
    self.endX = 0
    self.endY = 0
end

-- Start a new cutscene with given parameters
function cutscene:start(p1x, p1y, p2x, p2y, time)
    self.startX = p1x
    self.startY = p1y
    self.endX = p2x
    self.endY = p2y
    self.time = time
    self.elapsed = 0
    self.active = true
end

-- Update the cutscene, called in your game loop
function cutscene:update(dt)
    if not self.active then return end

    self.elapsed = self.elapsed + dt

    -- Stop the cutscene once the time is up
    if self.elapsed >= self.time then
        self.elapsed = self.time
        self.active = false
    end

    -- Calculate progress
    local progress = self.elapsed / self.time

    -- Interpolate positions
    self.posX = self.startX + (self.endX - self.startX) * progress
    self.posY = self.startY + (self.endY - self.startY) * progress
end

-- Get the current position during the cutscene
function cutscene:getPosition()
    return self.posX, self.posY
end

return cutscene
