local progression = {
    objLocations = gameMap.layers["misc-items"].objects
}


function progression:update(dt)

end
function progression:keypressed(key) 
    if key == "e" then
        n = progression.objLocations
        -- player.inRangeFunction(player.findObject(n, "Brew Coffee"), objectives.checks["brewCoffee"] == false, 30, function() print("BREWED COFFEE") objectives.addCheck("brewCoffee") end)
        --player.inRangeFunction(player.findObject(n, "Brew Coffee"), true, 30, function() print("BREWED COFFEE") objectives.addCheck("brewCoffee") end)

    end

end
function progression:gamepadpressed(button) 


end
return progression