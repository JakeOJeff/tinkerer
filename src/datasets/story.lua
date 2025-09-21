local story = {
    currentSceneId = 1, -- Track the active scene
    scenes = {
        { 
            id = 1, 
            name = "Act 0", 
            description = "Perform Mundane Tasks around the house", 
            condition = function(player, objectives) 
                return (objectives.checks.brewCoffee ) 
            end, 
            action = function()
                print("Get musty smell off")
                story.advanceScene(2)
            end,
            completed = false 
        },
        { 
            id = 2, 
            name = "Linda's Body", 
            description = "Discover Linda's mutilated body.", 
            condition = function(player, objectives) 
                return player.location == "living_room" 
            end, 
            action = function()
                print("You found Linda's body. Her leg is missing.")
                story.advanceScene(3)
            end,
            completed = false 
        },
    }
}

-- Function to check and advance scenes
function story.checkTriggers(player, objectives)
    for _, scene in ipairs(story.scenes) do
        if not scene.completed and scene.id == story.currentSceneId and scene.condition(player, objectives) then
            scene.action()
            scene.completed = true
            break
        end
    end
end

-- Advance to the next scene
function story.advanceScene(nextSceneId)
    story.currentSceneId = nextSceneId -- Update the current active scene
    print("Scene advanced to: " .. nextSceneId)
end

-- Draw active scene description on screen
function story.draw()
    lg.setFont(fonts[6])
    for _, scene in ipairs(story.scenes) do
        if not scene.completed and scene.id == story.currentSceneId then
            love.graphics.print("Task: " .. scene.description, 10, 10)
            break
        end
    end
end

return story
