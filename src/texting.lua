local texting = {}

-- Element Data
local elements = require 'src.datasets.elements' -- Import elements data

-- Dynamic sizing based on window width and height
local headerFont = fonts[5]
local contactFonts = fonts[6]
local contactsDescriptionFont = fonts[7]
local textFont = fonts[6]

local leftDrawerWidth = wW * 0.25 -- 25% of the window width for the contact list
local rightDrawerWidth = wW * 0.68 -- 70% of the window width for the chat window
local drawerHeight = wH * 0.9 -- 90% of the window height for both drawers
local topBarHeight = textFont:getHeight() * 2 -- Dynamic height for top bar in chat window based on font size

-- Left Hand Drawer (Contact List)
local leftDrawX = wW * 0.02 -- 2% padding from the left side of the screen
local leftDrawY = wH * 0.05 -- 5% padding from the top
elements.leftDraw = {
    x = leftDrawX,
    y = leftDrawY,
    w = leftDrawerWidth,
    h = drawerHeight
}

-- Right Hand Drawer (Chat Window)
local rightDrawX = leftDrawX + leftDrawerWidth + wW * 0.03 -- 3% space between the two drawers
local rightDrawY = leftDrawY
elements.rightDraw = {
    x = rightDrawX,
    y = rightDrawY,
    w = rightDrawerWidth,
    h = drawerHeight
}

-- Call
local textIncoming = "INCOMING CALL"
local textMom = "MOM"
local callTime = 0
-- Libraries
local cron = require 'src.libs.cron' -- Timer library for managing timed events

-- Datasets

-- Assets
local icons = {
    search = lg.newImage("assets/icons/chat/search.png"), -- Search icon
    mouse = love.mouse.newCursor("assets/icons/chat/mouse.png"), -- Mouse cursor
    txt = love.mouse.newCursor("assets/icons/chat/text.png"), -- Text cursor for typing
    call = lg.newImage("assets/icons/chat/call.png"),
    videocall = lg.newImage("assets/icons/chat/videocall.png"),
    accept = lg.newImage("assets/icons/chat/accept.png"),
    decline = lg.newImage("assets/icons/chat/decline.png")
}

-- Temporary Variables for Chat Management
local chatList = {
    "", "", "", "", "", ".", "..", "...", ".", "..", "...",
    "Where are you! I have been calling you for hours!!"
}
local momTextingDone = false -- Flag to check if all messages from mom are displayed
local currentChat = 1 -- Tracks the current message being displayed
local textToBe = "Mom, I am safe here, don't worry about me" -- Message the player is typing
local displayTTB = "" -- Displaying text during typing
local typePosition = 0 -- Position in the typed message
local startTyping = false -- Flag to begin typing
local typingDone = false -- Flag to check if typing is completed
local startCall = false -- Flag for initiating a call

local hoverAccept = false
local hoverDecline = false
local pickedUp = false
-- Settings
love.mouse.setVisible = false -- Hide the default mouse cursor
--[[sounds.notif1:setVolume(.1) -- Set notification sound volume
sounds.keyAudio:setVolume(.1) -- Set key press sound volume
sounds.spacekeyAudio:setVolume(.4) -- Set space key sound volume
sounds.ringtone:setVolume(.4)
sounds.axeslash:setVolume(.3)
sounds.scream1:setVolume(.2)]]
-- Load Function to Initialize Timers
function texting:load()
    timers = {
        init = cron.every(60, nextChat), -- Timer for displaying the next chat message
        type = cron.every(10, typeNext) -- Timer for typing out the message
    }
end

-- Update Function for Handling Timers and User Input
function texting:update(dt)
     headerFont = fonts[5]
 contactFonts = fonts[6]
 contactsDescriptionFont = fonts[7]
 textFont = fonts[6]
    topBarHeight = textFont:getHeight() * 1.5 -- Adjust the top bar height dynamically

    -- Chat message management
    if currentChat <= #chatList then
        timers.init:update(1) -- Update the timer for new messages
    else
        momTextingDone = true -- Mark that all messages from mom are displayed
    end

    -- Typing message management
    if typePosition < string.len(textToBe) + 20 and startTyping then
        timers.type:update(1) -- Update the typing timer if typing is in progress
    end

    if startCall then
        sounds.ringtone:play()
    end

    -- Change cursor to text cursor if hovering over the chat window
    if love.mouse.getX() < elements.rightDraw.x + elements.rightDraw.w and
        love.mouse.getX() > elements.rightDraw.x and love.mouse.getY() <
        elements.rightDraw.y + elements.rightDraw.h - 10 and love.mouse.getY() >
        elements.rightDraw.y + elements.rightDraw.h - topBarHeight - 10 then
        love.mouse.setCursor(icons.txt)
        if love.mouse.isDown(1) and momTextingDone then
            startTyping = true -- Begin typing if left mouse button is pressed
        end
    else
        love.mouse.setCursor(icons.mouse) -- Revert to normal mouse cursor
    end

    if love.mouse.isDown(1) then
        if hoverAccept then
            pickedUp = true
            --texting.setScene("game")
        end
    end
    if pickedUp then
        callTime = callTime + 1 * dt
        textMom = "0:0"..tostring(math.floor(callTime))
        textIncoming = "On Call : MOM"
        sounds.ringtone:stop()
        sounds.scream1:play()
        local pan = -.4  -- Adjust the pan for left/right positioning
        local distanceBehind = -0.5 -- Distance behind the listener
        sounds.axeslash:setPosition(pan, 0, distanceBehind)
        sounds.axeslash:play()
    end

    if math.floor(callTime) > 4 then
        texting.setScene("game")
        resetScale(3) -- Update zoom value, function exists in main.lua
        sounds.scream1:stop()
        sounds.axeslash:stop()
    end
    elements.update(dt) -- Update the elements
end

-- Draw Function for Rendering the UI and Chat
function texting:draw()
    -- Set background color


    lg.setBackgroundColor(convertRGB(18, 18, 18))
    lg.setFont(fonts[6]) -- Use smallest font for default rendering

    -- Draw the left-hand drawer (Contact List) with shadow
    local shadowOffset = 5 * wW / defW
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", elements.leftDraw.x + shadowOffset,
                 elements.leftDraw.y + shadowOffset, elements.leftDraw.w,
                 elements.leftDraw.h, 15, 15)
    lg.setColor(convertRGB(35, 35, 35))
    lg.rectangle("fill", elements.leftDraw.x, elements.leftDraw.y,
                 elements.leftDraw.w, elements.leftDraw.h, 15, 15)

    -- Draw the right-hand drawer (Chat Window) with shadow
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", elements.rightDraw.x + shadowOffset,
                 elements.rightDraw.y + shadowOffset, elements.rightDraw.w,
                 elements.rightDraw.h, 15, 15)
    lg.setColor(convertRGB(35, 35, 35))
    lg.rectangle("fill", elements.rightDraw.x, elements.rightDraw.y,
                 elements.rightDraw.w, elements.rightDraw.h, 15, 15)

    -- Left-hand drawer elements (Contacts) rendering
    lg.setColor(convertRGB(26, 26, 26))
    local elementHeight = elements.leftDraw.h / 13 + fonts[6]:getHeight()
    local padding = elements.leftDraw.w / 25
    local spacing = elementHeight / 6
    local elementStartY = elements.leftDraw.y * 1.3
    local imageSize = elementHeight * 0.9 -- Dynamic image size for contacts

    for i = 1, #elements.leftDrawChildren do
        local currentY = elementStartY + (i - 1) * (elementHeight + spacing)
        lg.rectangle("fill", elements.leftDraw.x + padding, currentY,
                     elements.leftDraw.w - padding * 2, elementHeight, 10, 10)

        local lDC = elements.leftDrawChildren
        lg.setColor(1, 1, 1)

        -- Draw contact images dynamically sized
        if lDC[i].img then
            local imgX = elements.leftDraw.x + padding
            local imgY = currentY + (elementHeight - imageSize) / 2
            lg.draw(lDC[i].img, imgX, imgY, 0,
                    imageSize / lDC[i].img:getWidth(),
                    imageSize / lDC[i].img:getHeight())
            lg.setLineWidth(imageSize / 20)
            lg.circle('line', imgX + imageSize / 2, imgY + imageSize / 2,
                      (imageSize / 2))
        end

        lg.setFont(contactFonts) -- Smallest font for names
        lg.print(lDC[i].name, elements.leftDraw.x + imageSize + padding * 1.5,
                 currentY + (elementHeight - imageSize) / 2 + padding * 0.2)
        lg.setFont(contactsDescriptionFont) -- Smaller font for statuses
        lg.setColor(0.7, 0.7, .7)
        lg.printf(lDC[i].status,
                  elements.leftDraw.x + imageSize + padding * 1.5, currentY +
                      (elementHeight - imageSize) / 2 + padding * .05 +
                      contactFonts:getHeight(), elements.leftDraw.w / 1.5)
        -- Optional hover effect
        if elements.leftDrawChildren[i].isHovered then
            lg.setColor(0.5, 0.5, 0.5, 0.5)
            lg.rectangle("fill", elements.leftDraw.x + padding, currentY,
                         elements.leftDraw.w - padding * 2, elementHeight, 10,
                         10)
        end
        lg.setColor(convertRGB(26, 26, 26))
    end

    -- Draw chat window for "MOM"
    lg.setColor(convertRGB(45, 45, 45))
    lg.rectangle("fill", elements.rightDraw.x, elements.rightDraw.y, -- Top text
                 elements.rightDraw.w, headerFont:getHeight("MOM"), 10, 10)
    lg.setColor(convertRGB(55, 55, 55))
    lg.rectangle("fill", elements.rightDraw.x, 
                 elements.rightDraw.y + elements.rightDraw.h - topBarHeight,
                 elements.rightDraw.w, topBarHeight, 10, 10)  -- Bottom Bar text
    lg.setFont(headerFont) -- Header font for "MOM"
    lg.setColor(1, 1, 1)
    local momNamePadding = 15
    lg.print("MOM", elements.rightDraw.x + momNamePadding, elements.rightDraw.y)
    local imageSizeBar = 0.8 * headerFont:getHeight()
    if icons.call then
        local imgX = elements.rightDraw.x + elements.rightDraw.w * .8
        local imgY = elements.rightDraw.y + (headerFont:getHeight() - imageSizeBar) /
                         2 -- Center the image vertically
        lg.draw(icons.call, imgX, imgY, 0, imageSizeBar / icons.call:getWidth(),
                imageSizeBar / icons.call:getHeight()) -- Fixed typo here
    end
    if icons.call then
        local imgX = elements.rightDraw.x + elements.rightDraw.w * .9
        local imgY = elements.rightDraw.y + (headerFont:getHeight() - imageSizeBar) /
                         2 -- Center the image vertically
        lg.draw(icons.videocall, imgX, imgY, 0,
                imageSizeBar / icons.videocall:getWidth(),
                imageSizeBar / icons.videocall:getHeight()) -- Fixed typo here
    end

    -- Typing display
    if not typingDone then
        lg.setFont(textFont)
        lg.print(displayTTB, elements.rightDraw.x + momNamePadding,
                 elements.rightDraw.y + elements.rightDraw.h - topBarHeight)
    end

    -- Render chat messages from "MOM"
    local chatPadding = 10
    local padding = 10 -- Padding inside chat bubbles
    local chatY = elements.rightDraw.y + headerFont:getHeight("MOM") + chatPadding
    local maxWidth = elements.rightDraw.w - (chatPadding * 2) - padding

    lg.setFont(textFont)
    for i = 1, #elements.chat do
        wrappedText, lines = textFont:getWrap(elements.chat[i].text, maxWidth)
        local text_height = textFont:getHeight() * #lines
        local chatWidth = wrappedText + 2 * padding
        local chatHeight = text_height + 2 * padding
        lg.setColor(convertRGB(55, 55, 55))
        lg.rectangle("fill", elements.rightDraw.x + chatPadding, chatY,
                     chatWidth, chatHeight, 10, 10)
        lg.setFont(textFont)
        lg.setColor(elements.chat[i].textColor)
        lg.printf(elements.chat[i].text,
                  elements.rightDraw.x + chatPadding + padding, chatY + padding,
                  chatWidth, "left")
        chatY = chatY + chatHeight + chatPadding
    end

    -- Render player's response message
    if typingDone then
        wr, li = textFont:getWrap(textToBe, maxWidth)
        local tH = textFont:getHeight() * #li
        local cWidth = wr + 2 * padding
        local cHeight = tH + 2 * padding
        lg.setColor(convertRGB(87, 137, 145))
        lg.rectangle("fill", elements.rightDraw.x + elements.rightDraw.w -
                         chatPadding - cWidth, chatY, cWidth, cHeight, 10, 10)
        lg.setFont(textFont)
        lg.setColor(1, 1, 1)
        lg.printf(textToBe, elements.rightDraw.x + elements.rightDraw.w -
                      chatPadding - cWidth + padding, chatY + padding, cWidth,
                  "left")
    end

    -- Render call dialog if it is initiated
    if startCall then
    -- Draw shadow
    lg.setColor(0, 0, 0, 0.5)
    lg.rectangle("fill", elements.call.x + shadowOffset, elements.call.y + shadowOffset,
                 elements.call.w, elements.call.h, 15, 15)

    -- Draw call frame
    lg.setColor(convertRGB(40, 40, 40))
    lg.rectangle("fill", elements.call.x, elements.call.y, elements.call.w, elements.call.h, 15, 15)

    -- Set the font and draw text
    lg.setFont(contactFonts)

    -- "INCOMING CALL"
    local textXIncoming = elements.call.x + (elements.call.w ) / 2 - contactFonts:getWidth(textIncoming)/2
    local textYIncoming = elements.call.y + 20
    lg.setColor(1, 1, 1)
    lg.print(textIncoming, textXIncoming, textYIncoming)
    lg.setFont(headerFont)

    -- "MOM"
    local textXMom = elements.call.x + (elements.call.w - headerFont:getWidth(textMom)) / 2
    local textYMom = textYIncoming + headerFont:getHeight()
    lg.print(textMom, textXMom, textYMom)

    -- Buttons
    local sizeBarCall = 0.2 * elements.call.w
    local totalButtonWidth = 2 * sizeBarCall + 20 -- Two buttons + padding
    local buttonsStartX = elements.call.x + (elements.call.w - totalButtonWidth) / 2
    local imgY = elements.call.y + (elements.call.h / 1.5) - (sizeBarCall / 2)

    -- Mouse Position
    local mx, my = love.mouse.getPosition()

    -- Accept Button
    if icons.accept then
        local acceptImgX = buttonsStartX
        hoverAccept = mx >= acceptImgX and mx <= acceptImgX + sizeBarCall and
                      my >= imgY and my <= imgY + sizeBarCall
        lg.draw(icons.accept, acceptImgX, imgY, 0,
                sizeBarCall / icons.accept:getWidth(),
                sizeBarCall / icons.accept:getHeight())
    end

    -- Decline Button
    if icons.decline then
        local declineImgX = buttonsStartX + sizeBarCall + 20
        hoverDecline = mx >= declineImgX and mx <= declineImgX + sizeBarCall and
                       my >= imgY and my <= imgY + sizeBarCall
        lg.draw(icons.decline, declineImgX, imgY, 0,
                sizeBarCall / icons.decline:getWidth(),
                sizeBarCall / icons.decline:getHeight())
    end
end


end

function texting:gamepadpressed(joystick, button)
    if button == "a" then
        if not startCall and momTextingDone then
            startTyping = true
        elseif startCall then
            pickedUp = true
        end

    end
end


-- Timer Functions for Chat and Typing

-- Function to display the next chat message
function nextChat()
    if #elements.chat > 2 then
        table.remove(elements.chat, #elements.chat) -- Limit chat messages to the most recent ones
    end
    if chatList[currentChat] ~= "" then
        table.insert(elements.chat,
                     {text = chatList[currentChat], textColor = {1, 1, 1}})
        local textLimit = 38
        elements.leftDrawChildren[1].status =
            string.sub(chatList[currentChat], 1, textLimit)
        if string.len(chatList[currentChat]) > textLimit then
            elements.leftDrawChildren[1].status =
                elements.leftDrawChildren[1].status .. "... ~ now"
        end
    end
    if currentChat == #chatList then
        sounds.notif1:play() -- Play notification sound when all messages are displayed
    end
    currentChat = currentChat + 1 -- Move to the next message
end

-- Function to simulate typing the player's message
function typeNext()
    typePosition = typePosition + 1
    sounds.keyAudio:stop()

    displayTTB = string.sub(textToBe, 0, typePosition)

    if typePosition == string.len(textToBe) + 1 then
        sounds.spacekeyAudio:play() -- Play space key sound when typing is done
        typingDone = true
        elements.leftDrawChildren[1].status = "Sent : " ..
                                                  string.sub(textToBe, 1, 30) ..
                                                  "... ~ now"
    elseif typePosition == string.len(textToBe) + 20 then
        startCall = true -- Trigger call event after typing
        elements.leftDrawChildren[1].status = "INCOMING CALL"
    elseif typePosition < string.len(textToBe) then
        sounds.keyAudio:play() -- Play typing sound

    end
end

return texting
