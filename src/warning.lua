-- Define the "cont" module
local warning = {}

-- Data Extraction
local contdata = require 'src.datasets.contdata'  -- Load conversation data
local inputs = require 'src.datasets.input'
local sounds = require 'src.datasets.sounds'

-- Warning text to display
local warningTexts = "Welcome back. This place might seem familiar—it should. What lies ahead may feel like déjà vu, like a path you’ve walked before. Maybe you have. The choices you’ll make might not seem important at first, but every small step leaves a mark. This isn’t a story about grand heroes or villains. It’s just you, here, now. Take your time. There’s no rush to see what’s waiting. After all, this is only a game... isn’t it?"

-- Variables
local img = inputs[settings.controls.keyboard.CHOOSE] -- Text for prompt to continue
local revealedText = "" -- Text revealed so far
local textParts = {} -- Table to hold split text segments
local revealTimer = 0 -- Timer to control text reveal speed
local revealSpeed = 2.5 -- Time between revealing each segment
local currentIndex = 1 -- Index of the current segment to reveal

-- Function to split the text by punctuation
local function splitTextByPunctuation(text)
    local parts = {}
    for segment in text:gmatch("[^.,!?;]*[.,!?;]?%s?") do
        table.insert(parts, segment)
    end
    return parts
end

-- Function to initialize the module
function warning:load()
    sounds.oldsong:play() -- Start playing the forest sound
    textParts = splitTextByPunctuation(warningTexts) -- Split the text into parts
    revealedText = "" -- Initialize revealed text
    currentIndex = 1 -- Start from the first segment
    revealTimer = 0 -- Reset the timer
end

-- Function to update timers and control text reveal
function warning:update(dt)
    joysticks = love.joystick.getJoysticks() -- Get connected joysticks

    -- Set prompt text based on input type (keyboard or gamepad)
    if #joysticks > 0 then
        img = inputs.gamepad[settings.controls.joystick.CHOOSE]
    else
        img = inputs[settings.controls.keyboard.CHOOSE]
    end

    -- Incrementally reveal text based on the timer
    if currentIndex <= #textParts then
        revealTimer = revealTimer + dt
        if revealTimer >= revealSpeed then
            revealedText = revealedText .. textParts[currentIndex]
            currentIndex = currentIndex + 1
            revealTimer = 0
        end
    end
end

-- Function to draw conversation text on the screen
function warning:draw()
    lg.setFont(fonts[4]) -- Set font for rendering text
    fo = {
        h = fonts[4].getHeight(fonts[4]),
        h2 = fonts[5].getHeight(fonts[5])
    }

    -- Draw the warning header
    lg.setColor(0.7, 0.1, 0.1)
    lg.print("WARNING", wW / 2 - fonts[4]:getWidth("WARNING") / 2, fo.h * 0.6)
    lg.setColor(1, 1, 1)

    -- Draw the revealed text
    lg.setFont(fonts[6])
    lg.printf(revealedText, 10, fo.h * 1.7, wW - 10, "center")

    -- Show prompt to continue if all text is revealed
    if currentIndex > #textParts then
        
        lg.setColor(0.7, 0.7, 0.7)
        lg.setFont(fonts[6]) -- Set font for rendering text

        local Dscale = scale * 0.7
        local textPress = "Press "
        local textContinue = " to Continue "
        local imgWidth = img:getWidth() * Dscale / 2
        local totalWidth = fonts[6]:getWidth(textPress) + imgWidth + fonts[6]:getWidth(textContinue)
        local startXPrompt = (wW - totalWidth) / 2

        -- Draw the text and image, starting at the calculated position
        lg.print(textPress, startXPrompt, wH - fo.h)
        lg.draw(img, startXPrompt + fonts[6]:getWidth(textPress), wH - fo.h * 0.95, 0, Dscale / 2)
        lg.print(textContinue, startXPrompt + fonts[6]:getWidth(textPress) + imgWidth, wH - fo.h)
        lg.setColor(1, 1, 1)
    end

    globalDraw() -- Draw any additional global elements
end

-- Function to handle keypress events for progression
function warning:keypressed(key)
    if (key == settings.controls.keyboard.CHOOSE or key == "return") and currentIndex > #textParts then
        globalSoundStop()
        warning.setScene("cont")
    end
end

-- Function to handle gamepad button press for progression
function warning:gamepadpressed(joystick, button)
    if button == settings.controls.joystick.CHOOSE and currentIndex > #textParts then
        globalSoundStop()
        warning.setScene("cont")
    end
end

-- Return the cont module to allow access from other files
return warning
