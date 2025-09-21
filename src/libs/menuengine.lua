-- Menu Engine with Button and Joystick Support
local menuengine = {}
menuengine.VERSION = "1.0.0"

-- Defaults
menuengine.settings = {
    disabled = false,
    args = nil,
    colorSelected = {0.8, 0.4, 0.4},
    colorNormal = {1, 1, 1},
    defButW = 90,
    defButH = 20,
    buttonSpacing = 10,
    sndMove = nil,
    sndSuccess = nil,
    mouseDisabled = false,
    joystickDeadZone = .9,
    joystickTimer = 0,
    joystickCooldown = .5
}

-- Collect every menu
local menus = {}

-- Keyboard-Handling. Add your own Scancodes here if you want.
local KEY = {}
KEY.up = {scancodes = {"up", "w", "kp8"}}
KEY.down = {scancodes = {"down", "s", "kp2", "kp5"}}
KEY.accept = {scancodes = {"return", "kpenter", "kp0", "space"}}

-- Joystick
local activeJoystick = #joysticks > 0 and joysticks[settings.controls.joystick.selected_joystick] or nil

-- Constructor
function menuengine.new(x, y, font, parent)
    local self = {}

    self.entries = {}
    self.cursor = 1
    self.x = x or 0
    self.y = y or 0
    self.font = font or love.graphics.getFont()
    self.disabled = menuengine.settings.disabled
    self.parent = parent or nil

   
    -- Add Entry
    function self:addEntry(label, callback, args)

        local entry = {
            label = label,
            callback = callback or function() end,
            args = args or {},
            x = self.x,
            y = self.y + (#self.entries * (menuengine.settings.buttonHeight + menuengine.settings.buttonSpacing)),
            width = menuengine.settings.defButW * scale,
            height = menuengine.settings.defButW * scale, -- ISSUES HERE
            colorNormal = menuengine.settings.colorNormal,
            colorSelected = menuengine.settings.colorSelected,
        }
        table.insert(self.entries, entry)
    end

    -- Draw
    function self:draw()
        if self.disabled then return end -- Do nothing if the menu is disabled

        love.graphics.setFont(self.font)
        for i, entry in ipairs(self.entries) do
            if self.cursor == i then
                love.graphics.setColor(entry.colorSelected)
            else
                love.graphics.setColor(entry.colorNormal)
            end
            love.graphics.rectangle("fill", entry.x, entry.y, entry.width, entry.height)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(entry.label, self.font, entry.x, entry.y + (entry.height - self.font:getHeight()) / 2, entry.width, "center")
        end
    end

    -- Update
    function self:update(dt)
        if self.disabled then return end -- Do nothing if the menu is disabled

        -- To update height settings 



        menuengine.settings.joystickTimer = math.max(0, menuengine.settings.joystickTimer - dt)

        -- Keyboard
        if KEY.up.pressed then
            KEY.up.pressed = false
            self.cursor = (self.cursor - 2) % #self.entries + 1
        end
        if KEY.down.pressed then
            KEY.down.pressed = false
            self.cursor = self.cursor % #self.entries + 1
        end
        if KEY.accept.pressed then
            KEY.accept.pressed = false
            self.entries[self.cursor].callback(unpack(self.entries[self.cursor].args))
        end

        -- Joystick
        local axisY = activeJoystick:getAxis(2)
        if activeJoystick and menuengine.settings.joystickTimer == 0 then
            if axisY > menuengine.settings.joystickDeadZone then
                self.cursor = self.cursor % #self.entries + 1
                menuengine.settings.joystickTimer = menuengine.settings.joystickCooldown
            elseif axisY < -menuengine.settings.joystickDeadZone then
                self.cursor = (self.cursor - 2) % #self.entries + 1
                menuengine.settings.joystickTimer = menuengine.settings.joystickCooldown
            end
            

            if activeJoystick:isDown(1) then -- Button 1
                self.entries[self.cursor].callback(unpack(self.entries[self.cursor].args))
                activeJoystick:setVibration(1,1,.2)
            end
        elseif axisY == 0 then
            menuengine.settings.joystickTimer = 0
        end
    end

    -- UPDATING OF WIDTH VALUES
    --[[local maxLen = ""
    for i = 1, #self.entries do 
            if string.len(maxLen) > string.len(self.entries[i].label) then
                maxLen = self.entries[i].label
                self.entries[i].width = self.font:getWidth(maxLen)
            end
    end]]
    

    function self:setDisabled(value)
        self.disabled = value
    end

    table.insert(menus, self)
    return self
end

-- love.keypressed
function menuengine.keypressed(scancode)
    for action, keyData in pairs(KEY) do
        for _, key in ipairs(keyData.scancodes) do
            if scancode == key then
                keyData.pressed = true
            end
        end
    end
end

-- love.joystickadded
function menuengine.joystickadded(joystick)
    table.insert(joysticks, joystick)
    activeJoystick = joystick
end

-- love.joystickremoved
function menuengine.joystickremoved(joystick)
    for i, j in ipairs(joysticks) do
        if j == joystick then
            table.remove(joysticks, i)
            break
        end
    end
    activeJoystick = #joysticks > 0 and joysticks[1] or nil
end

-- Disable EVERY Menu
function menuengine.disable()
    for _, menu in ipairs(menus) do
        menu:setDisabled(true)
    end
end


-- Enable EVERY Menu
function menuengine.enable()
    for _, menu in ipairs(menus) do
        menu:setDisabled(false)
    end
end

return menuengine
