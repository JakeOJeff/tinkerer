local menu = {}

local menuengine = require 'src.libs.menuengine'
local mit = require 'src.datasets.menuitems'

local mainmenu = menuengine.new(100, 100, fonts[5])
local options = menuengine.new(100, 100, fonts[5])


function menu:load()
    mainmenu:addEntry("Start Game", function() mit.startGame(menu) end)
    mainmenu:addEntry("Options", function() print("Opening Options...") end)
    mainmenu:addEntry("Exit", function() mit.quitGame() end)
end

function menu:update(dt)
    mainmenu:update(dt)

end
function menu:draw()
    mainmenu:draw()

end
function menu:keypressed(scancode)
    menuengine.keypressed(scancode)
end
function menu:joystickadded(joystick)
    menuengine.joystickadded(joystick)
end

function menu:joystickremoved(joystick)
    menuengine.joystickremoved(joystick)
end


return menu