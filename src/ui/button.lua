local class = require 'src.libs.middleclass'

-- Define the Button class
local Button = class('Button')

-- Constructor for the Button class
function Button:initialize(x, y, width, height, text, onClick)
    self.x = x
    self.y = y
    self.width = width * scale
    self.height = height * scale
    self.text = text or "Button"
    self.onClick = onClick or function() end
    self.isHovered = false
    self.visible = true
end

-- Method to check if the button is hovered
function Button:isMouseOver()
    local mx, my = love.mouse.getPosition()
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

-- Update method to handle hover state
function Button:update(dt)
    self.isHovered = self:isMouseOver()
end

-- Method to handle mouse pressed events
function Button:mousepressed(x, y, button)
    if button == 1 and self:isMouseOver() then
        self.onClick()
    end
end

-- Draw method to render the button
function Button:draw()
    -- Set color based on hover state
    if self.isHovered then
        love.graphics.setColor(0.7, 0.7, 0.7) -- Light gray for hover
    else
        love.graphics.setColor(0.5, 0.5, 0.5) -- Dark gray for normal
    end
    
    if self.visible then
        -- Draw the button rectangle
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        -- Draw the button text
        love.graphics.setColor(1, 1, 1) -- White for text
        love.graphics.printf(self.text, self.x, self.y + self.height / 2 - 6, self.width, "center")
    end
end

return Button
