local SceneryInit = require("scenery")  -- Load the scenery module
-- HEY
-- Global settings
settings = require 'settings'

-- Temporary Global Classes
local sti = require 'src.libs.sti'     -- Library to load and handle tiled maps
class = require 'src.libs.middleclass'

-- Global Datasets
sounds = require 'src.datasets.sounds'
textQ = require 'src.datasets.textQ'
-- Global Vars
gameMap = sti('assets/maps/map.lua', {"box2d"}) -- Load the game map with Box2D physics

joysticks = love.joystick.getJoysticks()
-- Shortening love's modules to avoid repetitive use of 'love.'
lg = love.graphics  -- Graphics module for rendering
lk = love.keyboard  -- Keyboard module for input
lm = love.mouse     -- Mouse module for input
la = love.audio     -- Audio module for sound
defW = love.graphics.getWidth()  -- Default window width
defH = love.graphics.getHeight() -- Default window height
wW = defW  -- Current window width (initially same as default)
wH = defH  -- Current window height (initially same as default)
zoom = 3
scale = wH/defH * zoom
local decreasingFactor = scale

defaultFont = "assets/fonts/nihonium.ttf"  -- Path to the default font
defaultFontSize = 60  -- Default font size
fonts = {
    lg.newFont(defaultFont, defaultFontSize * decreasingFactor ),  -- Adjust main font
    lg.newFont(defaultFont, (defaultFontSize + 20)* decreasingFactor),  -- Adjust header font
    lg.newFont(defaultFont, (defaultFontSize - 20) *decreasingFactor),  -- Adjust smaller font
    lg.newFont(defaultFont, (defaultFontSize - 40)* decreasingFactor),  -- Adjust smallest font
    lg.newFont(defaultFont, (defaultFontSize - 44) *decreasingFactor) , -- Adjust smallestest font
    lg.newFont(defaultFont, (defaultFontSize - 52) *decreasingFactor) , -- Adjust smallestest font
    lg.newFont(defaultFont, (defaultFontSize - 56) *decreasingFactor) , -- Adjust smallestest font

}

-- Global Graphics Data
love.graphics.setDefaultFilter('nearest', 'nearest')  -- Set graphics filter for pixel-perfect rendering (no smoothing)

-- Initialize sceSnery module with different scenes (cont, texting, game)
local scenery = SceneryInit(
    { path = "src.warning"; key = "warning" ; default = false},
    { path = "src.game"; key = "game" ; default = true}  -- Load "game" scene, not the default
)
scenery:hook(love)  -- Hook scenery module to Love2D functions

-- Global Love Functions

-- Function called when the window is resized
function love.resize(w, h)
    wW = w  -- Update current window width
    wH = h  -- Update current window height
    resetScale(zoom)
    print(scale)

    local decreasingFactor = scale
    -- Adjust font sizes based on the new window width
    fonts = {
        lg.newFont(defaultFont, defaultFontSize * decreasingFactor ),  -- Adjust main font
        lg.newFont(defaultFont, (defaultFontSize + 20)* decreasingFactor),  -- Adjust header font
        lg.newFont(defaultFont, (defaultFontSize - 20) *decreasingFactor),  -- Adjust smaller font
        lg.newFont(defaultFont, (defaultFontSize - 40)* decreasingFactor),  -- Adjust smallest font
        lg.newFont(defaultFont, (defaultFontSize - 44) *decreasingFactor) , -- Adjust smallestest font
        lg.newFont(defaultFont, (defaultFontSize - 52) *decreasingFactor) , -- Adjust smallestest font
        lg.newFont(defaultFont, (defaultFontSize - 56) *decreasingFactor) , -- Adjust smallestest font
    
    }

end

function globalDraw()
    joysticks = love.joystick.getJoysticks()
    -- love.graphics.print(textQ.currentText)
end

function resetScale(z)
    zoom = z
    scale = wH/defH * zoom

end

-- Utility function to convert RGB values from 0-255 scale to 0-1 scale for Love2D
function convertRGB(r, g, b)
    return r/255, g/255, b/255  -- Return normalized RGB values
end

-- Utility function to calculate the distance between two points (x1, y1) and (x2, y2)
function dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)  -- Return the Euclidean distance
end

function distR(x1, y1, w1, h1, x2, y2, w2, h2)
    local point1x = (x1 * 2 + w1)/2
    local point2x = (x2 * 2 + w2)/2
    local point1y = (y1 * 2 + h1)/2
    local point2y = (y2 * 2 + h2)/2
    return dist(point1x, point1y, point2x, point2y)
end

function centerR(x1, y1, w1, h1)
    local point1x = (x1 * 2 + w1)/2
    local point1y = (y1 * 2 + h1)/2
    return point1x, point1y
end
function isColliding(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
    -- Calculate boundaries for rect1
    local r1Left = r1x
    local r1Right = r1x + r1w
    local r1Top = r1y
    local r1Bottom = r1y + r1h

    -- Calculate boundaries for rect2
    local r2Left = r2x
    local r2Right = r2x + r2w
    local r2Top = r2y
    local r2Bottom = r2y + r2h

    -- Check if rect1 is inside rect2
    if r1Left >= r2Left and r1Right <= r2Right and
       r1Top >= r2Top and r1Bottom <= r2Bottom then
        return true
    end

    -- Check if rect2 is inside rect1
    if r2Left >= r1Left and r2Right <= r1Right and
       r2Top >= r1Top and r2Bottom <= r1Bottom then
        return true
    end

    return false
end
