
local BackgroundLayer = require("app.layer.BackgroundLayer")
local Player = require("app.objects.Player")


local GameScene = class("GameScene", function()
    return display.newPhysicsScene("GameScene")
end)

-- 添加动画缓存
local function addAnimationCache()
    -- 添加Player的动画缓存
    local animationNames = {"flying", "drop", "die"}
    local animationNums = {4, 3, 4}

    for i=1,#animationNames do
        local frames = display.newFrames(animationNames[i] .. "%d.png", 1, animationNums[i])
        local animation = display.newAnimation(frames, 0.3/ animationNums[i])
        
        display.setAnimationCache(animationNames[i], animation)
    end

    --添加Bird的动画缓存
    local frames = display.newFrames("bird%d.png", 1, 9)
    local animation = display.newAnimation(frames, 0.5/9)
    animation:setDelayPerUnit(0.1)
    display.setAnimationCache("bird", animation)

    -- 添加hit的动画缓存
    local frames = display.newFrames("attack%d.png", 1, 6)
    local animation = display.newAnimation(frames, 0.3/6)
    display.setAnimationCache("hit", animation)

end

function GameScene:ctor()
    -- 设置物理世界
    self.world = self:getPhysicsWorld()
    self.world:setGravity(cc.p(0, -98))
    self.world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_NONE)

    -- 加载动画缓存
    addAnimationCache()

    -- 创建背景层
    self.backgroundLayer = BackgroundLayer.new()
        :addTo(self)

    -- 播放背景音乐
    --audio.playMusic("sound/background.mp3", true)
    -- 创建Player
    self.player = Player.new()
    self.player:setPosition(-20, display.top *2/3)
    self:addChild(self.player)
    self.player:createProgressBar()

    self:playerFlytoScene()
    self:addCollision()

    
end

function GameScene:Enter()

end

function GameScene:playerFlytoScene()
    local function startGame()
        self.player:getPhysicsBody():setGravityEnable(true)
        self.player:drop()
        self.backgroundLayer:startGame()
        self:setPlayerJump()
    end

    self.player:flying()

    transition:sequence()
    local action = cc.Sequence:create(cc.MoveTo:create(3, cc.p(display.cx, display.height *2/3)), cc.CallFunc:create(startGame))
    self.player:runAction(action)
end

function GameScene:addCollision()

    local function contactHandle(node)

        if node:getTag() == HEART_TAG then
            -- 当碰到心心时
            self.player:setHealth(self.player:getHealth() + 5)
            -- 例子效果
            local particle = cc.ParticleSystemQuad:create("particles/stars.plist")
            particle:setBlendAdditive(false)
            particle:setPosition(node:getPosition())
            self.backgroundLayer.map:addChild(particle)

            --audio.playSound("sound/heart.mp3", false)

            node:removeFromParent()

        elseif node:getTag() == GROUND_TAG then
            -- 当碰到边界时
            self.player:setHealth(self.player:getHealth() - 20)
            self.player:hit()
            --audio.playSound("sound/ground.mp3", false)

        elseif node:getTag() == BIRD_TAG then
            -- 当碰到鸟时
            self.player:setHealth(self.player:getHealth() - 7)
            self.player:hit()
        elseif node:getTag() == AIRSHIP_TAG then
            -- 当碰到飞艇时
            self.player:setHealth(self.player:getHealth() - 10)
            self.player:hit()
        end

    end

    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()

        contactHandle(a)
        contactHandle(b)

        return true
        
    end

    local function onContactSeperate(contact)
        -- 判断Plyaer是否死亡
        if self.player:getHealth() <= 0 then 
        self.backgroundLayer:unscheduleUpdate()
        self.player:die()

        local over = display.newSprite("image/over.png")
            :pos(display.cx, display.cy)
            :addTo(self)

        cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
    end
    end

    local listener = cc.EventListenerPhysicsContact:create()
    listener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    listener:registerScriptHandler(onContactSeperate, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

function GameScene:setPlayerJump()

    self.backgroundLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

            return self:onTouch(event.name, event.x, event.y)
        end)
    self.backgroundLayer:setTouchEnabled(true)

end


function GameScene:onTouch(name, x, y)
    if name == "began" then
        -- 点击开始，让Player有个向上的速度
        self.player:flying()
        self.player:getPhysicsBody():setVelocity(cc.p(0, 98))
        return true
    elseif name == "ended" then
        self.player:drop()
    end
end


function GameScene:Exit()


end


return GameScene