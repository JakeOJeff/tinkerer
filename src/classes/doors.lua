local doors = {currentDoor = nil, cooldown = 0, cooldownTime = 1} -- Add cooldown properties

local inRangeDoors = {} -- Track all doors in range for interaction
local currentPoint = 1
local doorCollider = false
-- Initialize door colliders for entry points in the map
doorsC = {}
if gameMap.layers["doors"] then -- Check if there’s a 'doors' layer
    for i, obj in pairs(gameMap.layers["doors"].objects) do
        table.insert(doorsC, obj) -- Store each door object in the doors table
    end
end

-- Initialize exit doors without colliders for exit points in the map
doorsEC = {}
if gameMap.layers["doors-exit"] then -- Check if there’s a 'doors-exit' layer
    for i, obj in pairs(gameMap.layers["doors-exit"].objects) do
        table.insert(doorsEC, obj) -- Store each exit door object in the doorsEC table
    end
end

function doors:update(dt)
    -- Update the cooldown timer
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - dt
    end

    if self.cooldown <= 0 then
    -- Track doors in range for interaction
    inRangeDoors = {} -- Clear the list each frame
    -- Check player proximity to each door in doorsC for interaction
    for i, obj in ipairs(doorsC) do
        -- Check if player is within a 50-pixel radius of a door
        local dista = distR(player.x, player.y, player.width, player.height,
                            obj.x, obj.y, obj.width, obj.height)


        -- Initialize the `soundPlayed` property if it doesn't exist
        --if obj.soundPlayed == nil then
            --obj.soundPlayed = false
        --end

        if dista < 60 then
            table.insert(inRangeDoors, obj) -- Add the door to the list of doors in range
            currentPoint = obj.properties["node"]
            doors.currentDoor = obj

            -- Play the sound only once
           --[[] if not obj.soundPlayed then
                sounds.door_open:play()
                obj.soundPlayed = true
            end]]
        else
            -- Reset `soundPlayed` when the player moves out of range
            obj.soundPlayed = false
        end
    end

    doorCollider = player.isMoving

    -- Update global inRange flag based on whether any doors are nearby
    inRange = #inRangeDoors > 0

    if inRange then
        gameMap.layers["Doors.Door" .. currentPoint .. ".DoorClosed"].visible =
            false
        gameMap.layers["Doors.Door" .. currentPoint .. ".DoorOpened"].visible =
            true
    else
        doors.currentDoor = nil
        for i = 1, #doorsC do
            gameMap.layers["Doors.Door" .. i .. ".DoorClosed"].visible = true
            gameMap.layers["Doors.Door" .. i .. ".DoorOpened"].visible = false
        end
    end
end
end

function doors:draw()
    -- Set visibility for each door's open/closed state
    for i, obj in ipairs(doorsC) do
        local isNearby = false

        -- Check if this door is within interaction range
        for _, nearbyDoor in ipairs(inRangeDoors) do
            if nearbyDoor == obj then
                isNearby = true
                break
            end
        end
        for i = 1, #gameMap.layers["doors"].objects do
            if gameMap.layers["Doors.Door" .. i .. ".DoorClosed"].visible then
                gameMap:drawLayer(gameMap.layers["Doors.Door" .. i .. ".DoorClosed"])
            end
            if gameMap.layers["Doors.Door" .. i .. ".DoorOpened"].visible then
                gameMap:drawLayer(gameMap.layers["Doors.Door" .. i .. ".DoorOpened"])
            end
        end

    end
end

function doors:keypressed(button)
    if button == "e" and self.cooldown <= 0 then -- Check if 'E' key is pressed and cooldown has elapsed
        if inRange then -- Check if player is in range of a door
            for _, obj in ipairs(inRangeDoors) do
                player.teleportToDoor(obj) -- Teleport player through each nearby door
            end
            inRangeDoors = {} -- Clear list after interaction
            self.cooldown = self.cooldownTime -- Reset cooldown
        end
    end
end

function doors:gamepadpressed(button)
    if button == "x" and self.cooldown <= 0 then -- Check if 'X' button is pressed and cooldown has elapsed
        if inRange then -- Check if player is in range of a door
            for _, obj in ipairs(inRangeDoors) do
                player.teleportToDoor(obj) -- Teleport player through each nearby door
            end
            inRangeDoors = {} -- Clear list after interaction
            self.cooldown = self.cooldownTime -- Reset cooldown
        end
    end
end

return doors
