local mitems = {currentDoor = nil, cooldown = 0, cooldownTime = 1} -- Add cooldown properties

local inRangeItems = {} -- Track all doors in range for interaction

-- Initialize door colliders for entry points in the map
misc_itemsC = {}
if gameMap.layers["misc-items"] then -- Check if there’s a 'doors' layer
    for i, obj in pairs(gameMap.layers["misc-items"].objects) do
        table.insert(misc_itemsC, obj) -- Store each door object in the doors table
    end
end



function mitems:update(dt)
    -- Update the cooldown timer
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - dt
    end

    if self.cooldown <= 0 then
    -- Track doors in range for interaction
    inRangeItems = {} -- Clear the list each frame
    -- Check player proximity to each door in doorsC for interaction
    for i, obj in ipairs(misc_itemsC) do
        -- Check if player is within a 50-pixel radius of a door
        local dista = distR(player.x, player.y, player.width, player.height,
                            obj.x, obj.y, obj.width, obj.height)


        

        if dista < 60 then
            table.insert(inRangeItems, obj) -- Add the door to the list of doors in range
            

        else
            
        end
    end


    -- Update global inRange flag based on whether any doors are nearby
    inRange = #inRangeItems > 0


end
end

function mitems:draw()
  
end

function mitems:keypressed(button)
    if button == "e" and self.cooldown <= 0 then -- Check if 'E' key is pressed and cooldown has elapsed
        if inRange then -- Check if player is in range of a door
            for _, obj in ipairs(inRangeItems) do

            end
            inRangeItems = {} -- Clear list after interaction
            self.cooldown = self.cooldownTime -- Reset cooldown
        end
    end
end

function mitems:gamepadpressed(button)
    if button == "x" and self.cooldown <= 0 then -- Check if 'X' button is pressed and cooldown has elapsed
        if inRange then -- Check if player is in range of a door
            for _, obj in ipairs(inRangeItems) do

            end
            inRangeItems = {} -- Clear list after interaction
            self.cooldown = self.cooldownTime -- Reset cooldown
        end
    end
end

return mitems
