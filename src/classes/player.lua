-- Define the player object
local player = {}

-- Player properties
player.tileX, player.tileY = 4, 41
player.x, player.y = player.tileX * 16, player.tileY * 16
player.speed = 86

-- Sprite and animations
player.spritesheet = love.graphics.newImage('assets/spritesheets/p2.png')
player.width, player.height = 16, 40

-- Animation grid and animations
local animSpeed = player.speed / 86 * 0.25
player.grid = anim8.newGrid(player.width, player.height,
                            player.spritesheet:getWidth(),
                            player.spritesheet:getHeight())

player.animations = {
    down = anim8.newAnimation(player.grid('1-4', 1), animSpeed),
    up = anim8.newAnimation(player.grid('1-4', 2), animSpeed),
    left = anim8.newAnimation(player.grid('1-4', 3), animSpeed),
    right = anim8.newAnimation(player.grid('1-4', 4), animSpeed),
    leftIdle = anim8.newAnimation(player.grid('1-8', 5), 0.4),
    rightIdle = anim8.newAnimation(player.grid('1-8', 6), 0.4),
    downIdle = anim8.newAnimation(player.grid('1-8', 7), 0.4),
    doors = anim8.newAnimation(player.grid('1-2', 8), 5)
}

player.anim = player.animations.left
player.animOrientation = "left"

-- Physics
player.collider = world:newBSGRectangleCollider(player.x, player.y +
                                                    (3 / 10 * player.height),
                                                player.width,
                                                1 / 5 * player.height, 1)
player.collider:setFixedRotation(true)
player.location = "bedroom"

player.isMoving = false
player.movement = true
player.visible = true
player.inventory = {}

-- Helper: Calculate direction and animation based on input
local function getMovementDirection()
    local vx, vy = 0, 0
    local xA, yA = 0, 0
    local x2A, y2A = 0, 0

    if #joysticks > 0 then
        xA, yA =
            joysticks[settings.controls.joystick.selected_joystick]:getAxis(1),
            joysticks[settings.controls.joystick.selected_joystick]:getAxis(2)
        x2A, y2A =
            joysticks[settings.controls.joystick.selected_joystick]:getAxis(3),
            joysticks[settings.controls.joystick.selected_joystick]:getAxis(4)
    end

    -- Turn angle
    if x2A > 0 then
        player.setAnim("right")
    elseif x2A < 0 then
        player.setAnim("left")
    end
    if y2A > 0 then player.setAnim("down") end

    local pms = settings.controls.keyboard
    if player.movement then
        if lk.isDown(pms.MOVEMENT_RIGHT, "right") or xA > 0 then
            vx = player.speed * (xA ~= 0 and xA or 1)
            player.setAnim("right")
        elseif lk.isDown(pms.MOVEMENT_LEFT, "left") or xA < 0 then
            vx = player.speed * (xA ~= 0 and xA or -1)
            player.setAnim("left")
        end

        if lk.isDown(pms.MOVEMENT_UP, "up") or yA < 0 then
            vy = player.speed * (yA ~= 0 and yA or -1)
            player.setAnim("up")
        elseif lk.isDown(pms.MOVEMENT_DOWN, "down") or yA > 0 then
            vy = player.speed * (yA ~= 0 and yA or 1)
            player.setAnim("down")
        end
    end

    if vx ~= 0 and vy ~= 0 then vx, vy = vx / math.sqrt(2), vy / math.sqrt(2) end

    return vx, vy, vx ~= 0 or vy ~= 0
end

-- Update player position and animations
function player.update(dt)
    local vx, vy, isMoving = getMovementDirection()
    player.isMoving = isMoving
    -- Idle animations
    if not isMoving then
        player.anim = player.animations[player.animOrientation .. "Idle"] or
                          player.anim
        if player.animOrientation == "up" then player.anim:gotoFrame(1) end
    end
    player.updateLocation(dt)
    -- Handle special animation frame
    if lk.isDown("i") and not isMoving then player.anim:gotoFrame(3) end

    -- Update physics and animation
    player.collider:setLinearVelocity(vx, vy)
    player.anim:update(dt)

    if isMoving then
        sounds.footsteps:play()
    else
        sounds.footsteps:stop()
    end
    -- Update position
    player.x = player.collider:getX() - player.width / 2
    player.y = player.collider:getY() -
                   (1 / 2.5 * player.height + player.height / 2)
end

function player.updateLocation(dt)
    for i, obj in pairs(gameMap.layers["locations"].objects) do
        pC = player.collider

        if isColliding(pC:getX(), pC:getY(), player.width, player.height, obj.x,
                       obj.y, obj.width, obj.height) then
            player.location = obj.properties.location
            -- print(player.location)
        end

    end
end
-- Teleport player to a door
function player.teleportToDoor(obj)
    if not obj then return end

    local targetNode = obj.properties["next"]
    for _, door in ipairs(doorsEC) do
        if targetNode == door.properties["node"] then
            local cenX, cenY = centerR(obj.x, obj.y, obj.width, obj.height)
            player.anim = (cenY < player.collider:getY()) and
                              player.animations.up or player.animations.down
            player.animOrientation = (cenY < player.collider:getY()) and "up" or
                                         "down"
            player.collider:setPosition(door.x, door.y)
            sounds.door_close:play()
        end
    end
end

function player.teleport(x, y) player.collider:setPosition(x, y) end
-- Draw player
function player.draw(x, y)
    if player.visible then
        player.anim:draw(player.spritesheet, player.x, player.y)
    end
end

function player.findObject(objLocation, objName)
    for i,v in pairs(objLocation) do
        if v.name == objName then
            return v
        end
    end
end

function player.inRange(obj, dist)
    local dista = distR(player.x, player.y, player.width, player.height, obj.x,
                        obj.y, obj.width, obj.height)

    if dista < dist then return true end
    return false
end
function player.inRangeFunction(obj, condition, dist, func)
    local cond = condition
    if cond == nil then cond = true end
    
    if player.inRange(obj, dist) and cond then func() end
end


function player.drawPrompt(obj, gamePadIco, keyboardIco)
    if not obj then return end

    lg.setFont(fonts[4]) -- Assuming fonts[4] is already set correctly

    -- Choose the correct icon based on input type
    local promptIcon = (#joysticks > 0 and gamePadIco or keyboardIco)
    if not promptIcon then return end -- Ensure the icon is valid

    -- Calculate the scaling factors for the icon
    local scaleX = obj.width / promptIcon:getWidth()
    local scaleY = obj.height / promptIcon:getHeight()

    -- Draw the icon at the object's position
    lg.draw(promptIcon, obj.x, obj.y, 0, scaleX, scaleY)

end

function player.setAnim(animation)
    player.animOrientation = animation
    player.anim = player.animations[animation]
end
function player.hasItem(itemname)
    for i = 1, #player.inventory do
        pInv = player.inventory[i]
        if pInv == itemname then return true, i end
    end
end
function player.addItem(itemname) table.insert(player.inventory, itemname) end
return player
