local elements = {}

-- Update function for managing the positions and sizes of different UI elements
function elements.update(dt)
    -- Define the position and size of the left drawer (contact list)
    elements.leftDraw = {
        x = wW * 0.03,  -- 3% of the window width from the left
        y = wH * 0.05,  -- 5% of the window height from the top
        w = wW * 0.25,  -- 25% of the window width for the contact list
        h = wH - (35 * wH/defH),  -- Height adjusted dynamically based on window size
        edge = 15  -- Edge rounding for the drawer
    }

    -- Define the position and size of the right drawer (chat window)
    elements.rightDraw = {
        x = elements.leftDraw.x + elements.leftDraw.w + 10,  -- Positioned 10 units right of the left drawer
        y = elements.leftDraw.y,  -- Same Y position as the left drawer
        w = wW * 0.68,  -- 68% of the window width for the chat window
        h = wH * 0.9,  -- 90% of the window height for the chat window
        edge = 15  -- Edge rounding for the drawer
    }

    -- Define the position and size of the call dialog box
    elements.call = {
        -- Centered horizontally in the right drawer with 50% width of the right drawer
        x = ((elements.rightDraw.x * 2) + elements.rightDraw.w) / 2 - (0.5 * elements.rightDraw.w) / 2,  
        -- Centered vertically in the right drawer with 60% height of the right drawer
        y = ((elements.rightDraw.y * 2) + elements.rightDraw.h) / 2 - (0.6 * elements.rightDraw.h) / 2,  
        w = 0.5 * elements.rightDraw.w,  -- 50% of the right drawer's width for the call dialog
        h = 0.6 * elements.rightDraw.h   -- 60% of the right drawer's height for the call dialog
    }
end

-- List of contacts in the left drawer (Contact List)
elements.leftDrawChildren = {
    {
        -- Image, name, and status of the contact "MOM"
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "MOM",  -- Contact name
        status = "MISSED CALL"  -- Contact's status message
    },
    {                
        
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "Stacyy",  -- Contact name
        status = "This place better not be musty ~ 6 hrs ago"  -- Contact's status message
    },
    {                
        
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "Victor",  -- Contact name
        status = "I don't like your tone ~ 7 hrs ago"  -- Contact's status message
    },
    {                
        
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "Linda",  -- Contact name
        status = "Are you sure about this ~ 7 hrs ago"  -- Contact's status message
    },
    {                
        
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "Thee Triples",  -- Contact name
        status = "You changed the profile picture"  -- Contact's status message
    },
    {                
        
        img = lg.newImage("assets/icons/chat/profiles/john.png"),
        name = "John",  -- Contact name
        status = "Sent : We'll reach early ~ 12 hrs ago"  -- Contact's status message
    }
}
-- List of contacts in the left drawer (Contact List)
elements.topRightDraw = {
    {
        -- Image, name, and status of the icon "Call"
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "Call",  -- Icon name
    },
    {
        -- Image, name, and status of the icon "MOM"
        img = lg.newImage("assets/icons/chat/profiles/mom.png"),
        name = "MOM",  -- Icon name
    },
}

-- Chat messages that appear in the chat window
elements.chat = {
    {
        -- First message indicating a missed call with red text color
        text = "MISSED CALL",
        textColor = {1, 0, 0}  -- Red color for the text
    },
    {
        -- Second message also indicating a missed call with red text color
        text = "MISSED CALL",
        textColor = {1, 0, 0}  -- Red color for the text
    },
}

return elements  -- Return the 'elements' table to make it accessible to other parts of the program
