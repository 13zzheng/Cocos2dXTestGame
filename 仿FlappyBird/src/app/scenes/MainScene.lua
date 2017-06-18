
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    self.background = display.newSprite("image/main.jpg", display.cx, display.cy)
    self:addChild(self.background)
    
    local title = display.newSprite("image/title.png", display.right *2/3, display.cy)
        :addTo(self)

    local moveUp = cc.MoveBy:create(0.7, cc.p(0, 10))
    local moveDown = cc.MoveBy:create(0.7, cc.p(0, -10))
    local sequnce = cc.Sequence:create(moveUp, moveDown)
    title:runAction(cc.RepeatForever:create(sequnce))

    local btnStart = cc.ui.UIPushButton.new({normal = "image/start1.png", pressed = "image/start2.png"})
        :align(display.CENTER, display.right *1/4, display.cy)
        :addTo(self)
    btnStart:onButtonClicked(function() display.replaceScene(require("app.scenes.GameScene").new(), "fade", 0.5, display.COLOR_BLACK) end)

    
    
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
