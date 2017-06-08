
local MainScene = class("MainScene", function()
    return display.newPhysicsScene("MainScene")
end)

local Plyaer = import("..roles.Player")
local Enemy1 = import("..roles.Enemy1")
local Enemy2 = import("..roles.Enemy2")
local Progress = import("..ui.Progress")
local PauseLayer = import("..ui.PauseLayer")
local scheduler = require("framework.scheduler")


function MainScene:addTouchLayer()
	local function onTouch(eventName, x, y)
		if eventName == "began" then
			--todo
			local state = self.player:getState()
			if state == "idle" or state == "walk" then
				self.player:walkTo({x = x, y = y})
			end

		end
	end

	self.layerTouch = display.newLayer()
	self.layerTouch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		return onTouch(event.name, event.x, event.y)
		end)

	self.layerTouch:setTouchEnabled(true)
	
	self.layerTouch:setPosition(CCPoint(0, 0))
	self.layerTouch:setContentSize(CCSize(display.width, display.height))
	self:addChild(self.layerTouch)
end


function MainScene:initUI()
	--添加分数

	self.remark = cc.ui.UILabel.new({
		UILableType = 5,
		text = "0",
		font = "futura-48.fnt",
		size = 50
		})

	self.remark:align(display.CENTER,display.cx,display.top-30)


	self:addChild(self.remark)
	--创建Player血量条
	self.progress = Progress.new("#player-progress-bg.png", "#player-progress-fill.png")
	self.progress:setPosition(display.left + self.progress:getContentSize().width/2, display.top - self.progress:getContentSize().height/2)
	self.player.progress = self.progress
	self:addChild(self.progress)

	--创建暂停按钮

	local btnPause = cc.ui.UIPushButton.new({normal = "#pause1.png", pressed = "#pause2.png"})
	btnPause:onButtonClicked(function(event) self:pause() end)
	btnPause:align(display.CENTER, display.right - 40, display.top - 40)
	self:addChild(btnPause)


end

function MainScene:addRemark(score)
	self.remark:setString(self.remark:getString() + score)
end

function MainScene:pause()
	display.pause()
	local pauselayer = PauseLayer.new()
	self:addChild(pauselayer)
	print("pause")
end

function MainScene:ctor()
	local world = self:getPhysicsWorld()

	world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)

	self.enemys = {}

	self:addTouchLayer()
	

	local background = display.newSprite("image/background.png", display.cx, display.cy)
	self:addChild(background)

	self.player = Plyaer.new()
	self.player:setPosition(display.left + self.player:getContentSize().width/2, display.cy)
	self:addChild(self.player)




	self:addEnemyByTime()

	

	self:initUI()
    
    --cc.NotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, function(_, enemy) self:clickEnemy(enemy) end, "CLICK_ENEMY")
end

function MainScene:addEnemyByTime()

	local function addEnemy1()
		print(#self.enemys)
		if #self.enemys >=2 then
    		return
    	end
		--敌人1
		self.enemy1 = Enemy1.new()
    	self.enemy1:setPosition(display.right - self.enemy1:getContentSize().width/2, display.cy)
    	self:addChild(self.enemy1)

    	self.enemys[#self.enemys + 1] = self.enemy1


    end

    local function addEnemy2()

    	if #self.enemys >=2 then
    		return
    	end
    	-- 敌人2
    	self.enemy2 = Enemy2.new()
    	self.enemy2:setPosition(display.right - self.enemy2:getContentSize().width/2 * 3, display.cy)
    	self:addChild(self.enemy2)

    	self.enemys[#self.enemys + 1] = self.enemy2
    
    end

    addEnemy1()
    addEnemy2()

   
    scheduler.scheduleGlobal(addEnemy1, 4)
	scheduler.scheduleGlobal(addEnemy2, 7)

end

function MainScene:enemyDead(enemy)
	
	for i, v in ipairs(self.enemys) do
		print("11111")
        if enemy == v then
        	print("remove!!!!")
            table.remove(self.enemys, i)
        end
    end
end


function MainScene:clickEnemy(enemy)
    
    if self.player.canAttack and enemy.isRange then
        if self.player:getState() ~= "attack" then
            self.player:doEvent("attack")
            
            if  enemy:getState() ~= 'hit' then
                enemy:doEvent("hit", self.player.attackNum)
            end
        end
    else
        local x,y = enemy:getPosition()

        local state = self.player:getState()
		if state == "idle" or state == "walk" then
			self.player:walkTo({x = x, y = y})
		end
        
    end
end


function MainScene:addCollision()

	

	local function onContactBegin(contact)

		print("contact !!!!")

        local a = contact:getShapeA():getBody():getNode()  
        local b = contact:getShapeB():getBody():getNode()

        

        if a:getTag() == PLAYER_TAG and b:getTag() == ENEMY_TAG then
        	
        elseif a:getTag() == ENEMY_TAG and b:getTag() == PLAYER_TAG then
        	--交换ab
        	a,b = b,a
        end
        a.canAttack = true
    	b.isRange = true
    	if b:getState() ~= "attack" then
			b:doEvent("attack")
			if b.isRange then
				a:doEvent("hit",b.attackNum)
			end
		end
        return true
    end

    local function onContactSeperate(contact) 
    	print("seperate !!!!!")

    	local a = contact:getShapeA():getBody():getNode()  
        local b = contact:getShapeB():getBody():getNode()

        if a:getTag() == PLAYER_TAG and b:getTag() == ENEMY_TAG then
        	
        elseif a:getTag() == ENEMY_TAG and b:getTag() == PLAYER_TAG then
        	--交换ab
        	a,b = b,a
        end
        a.canAttack = false
        b.isRange = false
    end


	local listener = cc.EventListenerPhysicsContact:create() 
	listener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
	listener:registerScriptHandler(onContactSeperate, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end


function MainScene:onEnter()
	self:addCollision()
end

function MainScene:onExit()

end

return MainScene