--
-- Author: Your Name
-- Date: 2017-06-06 22:35:39
--

local PhysicsManager = import("..scenes.PhysicsManager")
local Progress = import("..ui.Progress")


local Player = class("Player", function()
	local sprite = display.newSprite("#player1-1-1.png")
	return sprite
end)

function Player:addAnimation()
	local animationNames = {"walk", "attack", "dead", "hit", "skill"}
	local animationFrameNum = {4, 4, 4, 2, 4}

	for i = 1, #animationNames do

		local frames = display.newFrames("player1-" .. i .. "-%d.png", 1, animationFrameNum[i])
		
		local animation = nil
		if animationNames[i] == "attack" then
			animation = display.newAnimation(frames, 0.1)
		else
			animation = display.newAnimation(frames, 0.2)
		end

		animation:setRestoreOriginalFrame(true)
		display.setAnimationCache("player1-" .. animationNames[i], animation)
	end
end

function Player:ctor()
	self.health = 500
	self.attackNum = 40


	self:initPhysics()
	self:addAnimation()
	self:addStateMachine()
end

function Player:getState()
    return self.fsm_:getState()
end




function Player:initPhysics()

	self.body = cc.PhysicsBody:createBox(cc.size(self:getContentSize().width/4, self:getContentSize().height/4), cc.PhysicsMaterial(0.0, 0.0, 0.0), cc.p(0,0))
	
	self.body:setCategoryBitmask(0x0101)
	self.body:setContactTestBitmask(0x1111)
	self.body:setCollisionBitmask(0x1000)

	self.body:setGravityEnable(false)

	self:setPhysicsBody(self.body)
	self:setTag(PLAYER_TAG)
   
end

function Player:addStateMachine()
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
			{name = "stop", from = {"walk", "attack", "hit"}, to = "idle" },
			{name = "hit", from = {"walk", "idle", "attack"}, to = "hit"},
		},

		--状态改变的回调
		callbacks = {
			onbeforeidle = function(event) print("Player " .. event.name) self:idle() end,
			onbeforewalk = function(event) print("Player " .. event.name)  end,
			onbeforeattack = function(event) print("Player " .. event.name) self:attack() end,
			onbeforedead = function(event) print("Player " .. event.name) self:dead() end,
			onbeforehit = function(event) print("Player " .. event.name) self:hit(event.args[1]) end,
		},
	})

end


function Player:doEvent(event, ...)
	self.fsm_:doEvent(event, ...)
end


function Player:walkTo(pos, callback)

	--当上次移动没有完成时直接取消进行当前移动
	transition.stopTarget(self)
	self:doEvent("walk")
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
	local seq = transition.sequence({cc.MoveTo:create(5 * posDistance / display.width, destPosition), cc.CallFunc:create(moveStop)})
	transition.playAnimationForever(self, display.getAnimationCache("player1-walk"))
	self:runAction(seq)
	return true
end


function Player:hit(attack)
	transition.stopTarget(self)
	

    self.health = self.health - attack
    if self.health <= 0 then
    	self.health = 0
    	self.progress:setProgress(self.health *100/500)
    	self:doEvent("dead")
    	return
    end
    self.progress:setProgress(self.health *100/500)


    local function hitEnd()
        self:doEvent("stop")
    end

    transition.playAnimationOnce(self, display.getAnimationCache("player1-hit"), false, hitEnd)
end


function Player:attack()
	local function attackEnd()
		self:doEvent("stop")
	end
	transition.playAnimationOnce(self, display.getAnimationCache("player1-attack"), false, attackEnd)
end


function Player:dead()
	local function deadEnd()
		self:getParent():pause()
	end
	transition.playAnimationOnce(self, display.getAnimationCache("player1-dead"), false, deadEnd)
	
end


function Player:idle()
	transition.stopTarget(self)
	--停止时变为最初始的站立状态而不是动作到一半的状态
	self:setTexture("#player1-1-1.png")
	
end 


return Player