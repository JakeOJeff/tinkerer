-- Define the "cont" module
local cont = {}

-- Libraries
local cron = require 'src.libs.cron'  -- Library for handling timed events

-- Data Extraction
local contdata = require 'src.datasets.contdata'  -- Load conversation data
local inputs = require 'src.datasets.input'

-- Variables
local img = inputs[settings.controls.keyboard.CHOOSE]-- Text for prompt to continue

local textDatas = {  -- Stores the current conversation lines for display
    "",
    "",
    "",
    ""
}

-- Set volume levels for sound effects
       -- Background forest sound

-- Function to initialize the module
function cont:load()
    sounds.forest:play()               -- Start playing the forest sound
    c = cron.every(10, nextTask)       -- Every 10 seconds, call `nextTask` to display the next line
    cC = cron.after(3, clearTask)      -- After 3 seconds, call `clearTask` to clear displayed text
    iterV = 1                          -- Iterator for lines in the current conversation
    iterZ = 1                          -- Iterator for sets of conversation lines



    sounds.grassfootsteps:setRolloff(100)
    sounds.grassfootsteps:setRelative(true)
    sounds.grassfootsteps:setAttenuationDistances(1, 100) -- Min = 1, Max = 10

    sounds.knock:setRolloff(100)
    sounds.knock:setRelative(true)
end

-- Function to update timers and control prompt text
function cont:update(dt)
    c:update(.1)                      -- Update the cron timer every second

    joysticks = love.joystick.getJoysticks() -- Get connected joysticks
    -- Set prompt text based on input type (keyboard or gamepad)
    if #joysticks > 0 then
        img = inputs.gamepad[settings.controls.joystick.CHOOSE]
    else
        img = inputs[settings.controls.keyboard.CHOOSE]
    end
    
    -- Stop background sound if conversation set and line are finished
    if iterZ >= 6 and iterV >= 2 then
        local pan = iterV/#contdata[iterZ] - .5 -- Map to [-0.5, 0.5]

        -- Set the sound's 3D position to achieve panning
        sounds.grassfootsteps:setPosition(pan, 0, -math.sqrt(1 - pan * pan))
        sounds.grassfootsteps:play()
    end
end

-- Function to draw conversation text on the screen
function cont:draw()
    local usedFont = fonts[5]
    lg.setFont(usedFont)  -- Set font for rendering text
    fo = {
        h = usedFont.getHeight(usedFont)
    }

    -- Loop through each text line in textDatas and print it
    for i = 1, #textDatas do
        lg.print(textDatas[i], 10, (i - .9) * fo.h  )  -- Position each line with spacing
    end

    -- Show prompt to continue if all lines in current set are displayed
    if iterV > #contdata[iterZ] then
        
        lg.print("Press ", 10, wH - fo.h - 10)
        local Dscale = scale * .7
        lg.draw(img, 10 + usedFont:getWidth("Press "), wH - img:getHeight() * Dscale - 15, 0, Dscale)
        
        lg.print(" to Continue ", 10 + usedFont:getWidth("Press ") + img:getWidth() * Dscale, wH - fo.h - 10)
    end

    globalDraw() -- Draw any additional global elements
end

-- Function to handle keypress events for progression
function cont:keypressed(key)
    if key == settings.controls.keyboard.CHOOSE or key == "return" then
        if iterZ < #contdata and iterV >= #contdata[iterZ] then
            nextItem() -- Move to the next conversation set
        elseif iterZ == #contdata then
            endItem()  -- End the conversation and switch scene
        end
    end
end

-- Function to handle gamepad button press for progression
function cont:gamepadpressed(joystick, button)
    if button == settings.controls.joystick.CHOOSE then
        if iterZ < #contdata and iterV >= #contdata[iterZ] then
            nextItem() -- Move to the next conversation set
        elseif iterZ == #contdata then
            endItem()  -- End the conversation and switch scene
        end
    end
end

-- Function to load the next conversation line
function nextTask()
    if iterV <= #contdata[iterZ] then
        textDatas[iterV] = contdata[iterZ][iterV]  -- Add the next line of text
        iterV = iterV + 1                          -- Move to the next line
        sounds.keyAudio:play()                     -- Play key audio sound effect
    end
    if iterZ == 7 and iterV == 2 then
        local pan = .4 -- Map to [-0.5, 0.5]
        sounds.knock:setPosition(pan, 0, -math.sqrt(1 - pan * pan))
        sounds.knock:play()
       
    end
    if iterZ >= 6 then
        if #joysticks > 0 and settings.controls.joystick.vibration then
            joysticks[settings.controls.joystick.selected_joystick]:setVibration(1,1, .5)
        end
        sounds.heartbeat:play()
    end
end

-- Function to clear current conversation line after a delay
function clearTask()
    if iterV <= #contdata[iterZ] then
        iterV = iterV + 1                          -- Skip to the next task
        textDatas[iterV] = ""                      -- Clear the current text data
    end
end

-- Function to load the next conversation set
function nextItem()
    cC:update(1)  -- Update clearTask timer to reset text
    for i = 1, #textDatas do
        textDatas[i] = ""  -- Clear the displayed text lines
    end
    iterZ = iterZ + 1  -- Move to the next conversation set
    iterV = 1          -- Reset line iterator for new set
    if #joysticks > 0 and settings.controls.joystick.vibration then
        joysticks[settings.controls.joystick.selected_joystick]:setVibration(1,1, .5)
    end
    sounds.spacekeyAudio:play() -- Play sound for progressing conversation
end

-- Function to end the conversation and change scenes
function endItem()
    globalSoundStop()  -- Stop the forest background sound
    cont.setScene("texting")  -- Change to "texting" scene
end

-- Return the cont module to allow access from other files
return cont
