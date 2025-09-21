
local Frame = class("Frame")

-- Initialize the frame
function Frame:initialize()
    self.buttons = {} -- Store all buttons in the frame
end

-- Add a button to the frame
function Frame:addButton(button)
    table.insert(self.buttons, button)
end

-- Update all buttons in the frame
function Frame:update(dt)
    for _, button in ipairs(self.buttons) do
        if button.visible == true then
            button:update(dt)
        end
    end
end

-- Handle mouse click for all buttons in the frame
function Frame:mousepressed(mouseX, mouseY, button)
    if not self.visible then return end  -- Ensure the frame is visible before processing clicks
    for _, btn in ipairs(self.buttons) do
        if btn.visible then
            btn:mousepressed(button)
        end
    end
end


-- Draw all buttons in the frame
function Frame:draw()
    for _, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

-- Show or hide all buttons in the frame
function Frame:setVisible(visible)
    print("HELLO")
    for _, btn in ipairs(self.buttons) do
        btn.visible = visible
    end
end


return Frame
