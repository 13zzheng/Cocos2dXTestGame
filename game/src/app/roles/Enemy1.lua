--
-- Author: Your Name
-- Date: 2017-06-06 22:54:16
--
local Porgress = import("..ui.Progress")
local PhysicsManager = import("..scenes.PhysicsManager")
local scheduler = require("framework.scheduler")

local Enemy1 = class("Enemy1", function()
	local sprite = display.newSprite("#enemy1-1-1.png")
	return sprite
end)

function Enemy1:ctor()
	self.health = 100
	self.attackNum = 30
	self.isMove =false
	self.score = 10


    local function onTouch()
    	
    	--CCNotificationCenter:sharedNotificationCenter():postNotification("CLICK_ENEMY", self)
    	self:getParent():clickEnemy(self)

        return true
    end
    self:addAnimation()
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	
        return onTouch()
    end)

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(event)
		return onTouch()
	end)

    self:initPhysics()
	self:addAnimation()
	self:addUI()
	self:addStateMachine()
	
	local function onFrame()
		
		if not self.player then
			self.player = self:getParent().player
		end
		
		local pos = {x = cc.Node.getPositionX(self.player), y = cc.Node.getPositionY(self.player)}
		--pos = {x = 0, y = display.cy}
		local state = self:getState()
		if state== "idle" or state == "walk" then
			self:doEvent("walk", pos)
		end
		

		return true
	end


	self.run = scheduler.scheduleGlobal(onFrame, 1)
	--self:scheduleUpdate()
	--self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(event)
	--	return onFrame()
	--end)
end




function Enemy1:getState()
	return self.fsm_:getState()
end

function Enemy1:initPhysics()



	self.body = cc.PhysicsBody:createBox(cc.size(self:getContentSize().width/4, self:getContentSize().height/4), cc.PhysicsMaterial(0.0, 0.0, 0.0))
	


	self.body:setGravityEnable(false)
	
	self.body:setCategoryBitmask(0x0001)
	self.body:setContactTestBitmask(0x0100)
	self.body:setCollisionBitmask(0x0010)


	self:setPhysicsBody(self.body)

	self:setTag(ENEMY_TAG)
	
    self.body.isCanAttack = false

    
end


function Enemy1:addUI()
	self.progress = Porgress.new("#small-enemy-progress-bg.png", "#small-enemy-progress-fill.png")
	self.progress:setPosition(self:getContentSize().width * 2/3, self:getContentSize().height + self.progress:getContentSize().height/2)
	self:addChild(self.progress)
end

function Enemy1:addAnimation()
    local animationNames = {"walk", "attack", "dead", "hit"}
    local animationFrameNum = {3, 3, 3, 2}

    for i = 1, #animationNames do
        local frames = display.newFrames("enemy1-" .. i .. "-%d.png", 1, animationFrameNum[i])
        local animate = display.newAnimation(frames, 0.2)
        animate:setRestoreOriginalFrame(true)
        display.setAnimationCache("enemy1-" .. animationNames[i], animate)
    end
end

function Enemy1:addStateMachine()
	self.fsm_ = {}
	cc.GameObject.extend(self.fsm_)
		:addComponent("components.behavior.StateMachine")
		:exportMethods()

	self.fsm_:setupState({
		--初始状态
		initial = "idle",

		--构建事件与状态间的转换
		events = {
			{name = "walk", from = {"idle", "walk"}, to = "walk" },
			{name = "attack", from = {"idle", "walk"}, to = "attack" },
			{name = "dead", from = {"idle", "walk", "attack", "hit"}, to = "dead" },
			{name = "stop", from = {"walk", "attack", "hit", "dead"}, to = "idle" },
			{name = "hit", from = {"walk", "idle", "attack"}, to = "hit"},
		},

		--状态改变的回调
		callbacks = {
			onbeforeidle = function(event) print("enemy1 " .. event.name) self:idle() end,
			onbeforewalk = function(event) self:walkTo(event.args[1]) end,
			onbeforeattack = function(event) print("enemy1 " .. event.name) self:attack() end,
			onbeforedead = function(event) print("enemy1 " .. event.name) self:dead() end,
			onbeforehit = function(event) print("enemy1 " .. event.name) self:hit(event.args[1]) end,
			onleaveattack = function(event) print("Attack finish !")  end,
		},
	})
end

function Enemy1:doEvent(event, ...) 
	self.fsm_:doEvent(event, ...)
end

function Enemy1:walkTo(pos, callback)

	transition.stopTarget(self)
	local function moveStop()
		transition.stopTarget(self)
		self:doEvent("stop")
		if callback then
			--todo
			callback()
		end
	end

	local currentPosition = cc.p(cc.Node.getPositionX(self), cc.Node.getPositionY(self))
	local destPosition = cc.p(pos.x, pos.y) 
	local posDistance = cc.pGetDistance(currentPosition, destPosition)


	transition.execute(self,cc.MoveTo:create(7 * posDistance / display.width, destPosition),{  
        delay = 0,  
        onComplete = moveStop})  
	--local seq = transition.sequence({cc.MoveTo:create(7 * posDistance / display.width, destPosition), cc.CallFunc:create(moveStop)})
	transition.playAnimationForever(self, display.getAnimationCache("enemy1-walk"))
	--self:runAction(seq)
end

function Enemy1:idle()
	transition.stopTarget(self)
	--停止时变为最初始的站立状态而不是动作到一半的状态
	local frame = display.newSpriteFrame("enemy1-1-1.png")
	self:setSpriteFrame(frame)
end

function Enemy1:attack()
	transition.stopTarget(self)
	local function attackEnd()
        self:doEvent("stop")
    end

    transition.playAnimationOnce(self, display.getAnimationCache("enemy1-attack"), false, attackEnd)
end

function Enemy1:dead()

	local function remove()
		scheduler.unscheduleGlobal(self.run)
		self:getParent():enemyDead(self)
		self:getParent():addRemark(self.score)
		self:removeFromParent()
		self:doEvent("stop")
		self:cleanup()
	end
	transition.playAnimationOnce(self, display.getAnimationCache("enemy1-dead"), false , remove)
end

function Enemy1:hit(attack)
	transition.stopTarget(self)
	self.health = self.health - attack
	if self.health <=0 then
		self.health = 0
		self.progress:setProgress(self.health)
		self:doEvent("dead")
		return
	else
		self.progress:setProgress(self.health)
	end

	local function hitEnd()
        self:doEvent("stop")
    end

    transition.playAnimationOnce(self, display.getAnimationCache("enemy1-hit"), false, hitEnd)
end

function Enemy1:onExit()
    self:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
end

return Enemy1

