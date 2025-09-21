-- Define the main game table
local game = {}

-- Libraries
anim8 = require 'src.libs.anim8' -- Animation library for sprite animations
wf = require 'src.libs.windfield' -- Physics library for collision handling
cutscene = require 'src.libs.cutscene'
Camera = require 'src.libs.camera' -- HUMP Camera library

-- Datasets
objectives = require 'src.datasets.objectives'
story = require 'src.datasets.story'
progression = require 'src.datasets.progression'
inputs = require 'src.datasets.input'

-- Load Map
world = wf.newWorld(0, 0) -- Create a physics world with no gravity

-- Classes
local doors = require 'src.classes.doors'
player = require 'src.classes.player' -- Load the player class from file
lighting = require 'src.classes.lighting'

-- Initialize camera with HUMP
local camera = Camera(player.x, player.y)

-- Initialize misc Variables
-- Bobbing parameters
local bobbingAmplitude = .3 -- Adjust for the height of the bob (in pixels)
local bobbingSpeed = 7 -- Adjust for the speed of the bobbing effect
local bobbingTime = 0 -- A counter for the sine wave

-- Initialize wall colliders for solid objects in the map
wallsC = {}
if gameMap.layers["solid"] then -- Check if there’s a 'solid' layer
    for i, obj in pairs(gameMap.layers["solid"].objects) do
        local wallCollider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wallCollider:setType('static') -- Static collider for walls (no movement)
        table.insert(wallsC, wallCollider) -- Store each wall collider in the walls table
    end
end
-- Initialize props colliders for solid objects in the map
itemsC = {}
itemsP = {}
if gameMap.layers["item-solids"] then -- Check if there’s a 'solid' layer
    for i, obj in pairs(gameMap.layers["item-solids"].objects) do
        if obj.properties.collidable == true then
        local itemCollider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            itemCollider:setType('static') -- Static collider for walls (no movement)
            table.insert(itemsC, itemCollider) -- Store each wall collider in the walls table
        end
        table.insert(itemsP, obj)
    end
end
drawList = {
    
    "Floors",
    "Walls",
    "DoorFrame",
}

mainDrawList = {
    "Props",
    "Sprites"
}

uiDrawList = {
    "prompts"
}
-- Set map layers to be invisible in the game (only needed for collision logic)
gameMap.layers["solid"].visible = false
gameMap.layers["doors"].visible = false
gameMap.layers["doors-exit"].visible = false

-- Custom sprite layer
playerLayer = gameMap:addCustomLayer("Sprites")

-- custom ui layer
promptLayer = gameMap:addCustomLayer("prompts")

-- Load function to initialize game state
function game:load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- Prevent smoothing
    cutscene:init()
    camera:lookAt(math.floor(player.x), math.floor(player.y))

    -- Clamp wrapping for texture bleeding prevention
    if gameMap.tilesets then
        for _, tileset in ipairs(gameMap.tilesets) do
            if tileset.image then
                tileset.image:setWrap("clamp", "clamp")
            end
        end
    end
end

-- Update function, called every frame to update game state
function game:update(dt)
    world:update(dt) -- Update physics world
    player.update(dt) -- Update player state and position
    doors:update(dt)
    progression:update(dt)
    cutscene:update(dt)
    camera.scale = scale 
    lighting.update(dt)
    -- textQ.update(dt)
    -- Smoothly move the camera towards the player
    --[[local camX, camY = player.x, player.y
    camera:lockPosition(camX, camY)]]
    -- Increment the bobbing time only if the player is moving
    if player.isMoving then -- Assuming you have a flag to check movement
        bobbingTime = bobbingTime + dt * bobbingSpeed
    else
        bobbingTime = 0 -- Reset when the player stops
    end

    -- Calculate the bobbing offset using sine wave
    local bobbingOffset = math.sin(bobbingTime) * bobbingAmplitude
    if cutscene.active then
        local x, y = cutscene:getPosition()
        camera:lockPosition(x, y)
    else
        local camX = (player.x + player.width / 2) 
        local camY = (player.y + player.height / 2)+ bobbingOffset -- Add bobbing to x-axis
        camera:lockPosition(camX, camY)
    end
    -- Handle joystick zoom (if joysticks are connected)
    --[[if #joysticks > 0 then
        local xA = joysticks[settings.controls.joystick.selected_joystick]:getAxis(3)
        if zoom > 1 and zoom < 6 and xA ~= 0 then
            zoom = math.floor(zoom + xA / 100) -- Ensure integer scaling
            zoom = math.min(5, math.max(1, zoom)) -- Clamp zoom between 1 and 5
            scale = resetScale(zoom)
        end
    end]]

    for i, obj in pairs(itemsP) do
        -- Check if player's x position is within the prop's x range
        if player.collider:getX() >= obj.x and player.collider:getX() <= obj.x + obj.width then
            if player.collider:getY() < obj.y then
                mainDrawList = { "Sprites", "Props" }
            else
                mainDrawList = { "Props", "Sprites" }
            end
            break  -- Exit the loop once the condition is met
        end
    end
    story.checkTriggers(player, objectives)

end

-- Draw function for rendering game elements
function game:draw()
    -- Apply the camera transformation
    camera:attach()
    -- Draw the player relative to the camera position @override function
    playerLayer.draw = function()
        player.draw()
    end
    promptLayer.draw = function()
        player.drawPrompt(doors.currentDoor, inputs.gamepad[settings.controls.joystick.INTERACT], inputs[settings.controls.keyboard.INTERACT])
    end
    -- Background Map
    for i = 1, #drawList do
        if gameMap.layers[drawList[i]] then
            gameMap:drawLayer(gameMap.layers[drawList[i]])
        end
    end
    doors:draw()


    for i = 1, #mainDrawList do
        if gameMap.layers[mainDrawList[i]] then
            gameMap:drawLayer(gameMap.layers[mainDrawList[i]])

        end
    end

    for i = 1, #uiDrawList do
        if gameMap.layers[mainDrawList[i]] then
            gameMap:drawLayer(gameMap.layers[uiDrawList[i]])

        end
    end
    -- Draw interaction prompts

    -- Uncomment for debugging colliders
     --world:draw()

    -- Detach the camera transformation
    camera:detach()
    story.draw()

    -- lighting
    lighting.draw()

    -- Call any global drawing functions
    globalDraw()
end

-- Keypress event to handle interaction with doors using keyboard
function game:keypressed(button)
    doors:keypressed(button)
    progression:keypressed(button)

    -- Toggle fullscreen with F or F11
    if button == "f" or button == "f11" then
        love.window.setFullscreen(true, "desktop")
    end
    if button == "b" then
        lighting.settings.bw = not (lighting.settings.bw)
    end
    if button == "v" then
        lighting.settings.fog = not (lighting.settings.fog)
    end
    if button == "t" then
        cutscene:start(camera.x, camera.y, 300, 300, 10)
    end

    
    -- Exit fullscreen with Escape
    if button == "escape" then
        love.window.setFullscreen(false, "desktop")
    end
end

-- Gamepad button event to handle interaction with doors using a gamepad
function game:gamepadpressed(joystick, button)
    doors:gamepadpressed(button)
    progression:gamepadpressed(button)

    -- Toggle fullscreen with start and back buttons
    if button == "start" then
        love.window.setFullscreen(true, "desktop")
    end
    if button == "back" then
        love.window.setFullscreen(false, "desktop")
    end

end

-- Return the game table so it can be accessed by other modules
return game
