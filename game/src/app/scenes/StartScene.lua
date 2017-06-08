--
-- Author: Your Name
-- Date: 2017-06-07 22:12:16
--

local StartScene = class("Start", function()
	return display.newScene("StartScene")
end)

function StartScene:ctor()
	local background = display.newSprite("image/start-bg.jpg", x, y, params)
	background:setPosition(display.cx, display.cy)
	self:addChild(background)

	self:addUI()

end

function StartScene:addUI()
	local btnStart = cc.ui.UIPushButton.new({normal = "#start1.png", pressed = "#start2.png"})
	btnStart:onButtonClicked(function()
		display.replaceScene(require("app.scenes.MainScene").new(), "fade", 0.6, display.COLOR_WHITE)
	end)

	btnStart:setPosition(display.cx, display.cy)
	self:addChild(btnStart)

end




return StartScene