local mit = {}

function mit.startGame(currentScene)
    currentScene.setScene("recommendations")
end

function mit.quitGame()
    love.event.quit()
end

function mit.back(menu)
    if menu.parent then
        menuengine.disable()
        menu.parent.disabled = false
    end
end
function mit.enter(menu)
    menuengine.disable()
    menu.disabled = false
end

return mit