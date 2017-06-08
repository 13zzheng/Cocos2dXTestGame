--
-- Author: Your Name
-- Date: 2017-06-07 14:10:20
--

local PauseLayer = class("PauseLayer", function()
	return display.newColorLayer(cc.c4b(162, 162, 162, 128))
	end)

function PauseLayer:ctor()
	self:addUI()
	self:addTouch()
end


function PauseLayer:addUI()
	--设置背景图片
	local background = display.newSprite("#pause-bg.png")
	background:setPosition(display.cx, display.cy)
	self:addChild(background)

	local backgroundSize = background:getContentSize()

	--设置回到主界面按钮
	local btnHome = cc.ui.UIPushButton.new({normal = "#home-1.png", pressed = "#home-2.png"})
	btnHome:onButtonClicked(function (event) self:home() end )
	btnHome:align(display.CENTER, backgroundSize.width/3, backgroundSize.height/2)
	background:addChild(btnHome)

	--设置返回游戏按钮
	local btnResume = cc.ui.UIPushButton.new({normal = "#continue-1.png", pressed = "#continue-2.png"})
	btnResume:onButtonClicked(function(event) self:resume() end)
	btnResume:align(display.CENTER, backgroundSize.width*2/3, backgroundSize.height/2)
	background:addChild(btnResume)


end


function PauseLayer:addTouch()
	--用于捕获触摸事件，暂停时无法对游戏进行操作

	
	local function onTouch(eventName, x, y)

	end

	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		return onTouch(event.name, event.x, event.y)
	end)

	self:setTouchEnabled(true)
end

function PauseLayer:home()
	display.resume()
	self:removeFromParent()
	display.replaceScene(require("app.scenes.StartScene").new(), "fade", 0.6, display.COLOR_WHITE)
end


function PauseLayer:resume()
	display.resume()
	self:removeFromParent()
end

return PauseLayer