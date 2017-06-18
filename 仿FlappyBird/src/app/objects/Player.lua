
local Player = class("Player", function()

    return display.newSprite("#flying1.png")
end)


function Player:ctor()
    self.maxHealth = 100
    self.currentHealth = self.maxHealth
    local body = cc.PhysicsBody:createBox(self:getContentSize(), cc.PHYSICSBODY_MATERIAL_DEFAULT, cc.p(0, 0))
    body:setGravityEnable(false)
    
    body:setCategoryBitmask(0x1110)
    body:setContactTestBitmask(0x1111)
    body:setCollisionBitmask(0x1000)

    body:setRotationEnable(false)
    self:setPhysicsBody(body)
    self:setTag(PLAYER_TAG)

    
    
    
end

function Player:createProgressBar()
    local progress = display.newSprite("image/progress1.png")
    progress.fill = display.newProgressTimer("image/progress2.png", display.PROGRESS_TIMER_BAR)
    progress.fill:setMidpoint(cc.p(0, 0.5))
    progress.fill:setBarChangeRate(cc.p(1, 0, 0))

    progress.fill:setPosition(progress:getContentSize().width / 2, progress:getContentSize().height / 2)
    progress.fill:setPercentage(self.currentHealth / self.maxHealth * 100)
    progress:addChild(progress.fill)

    --设置锚点
    progress:setAnchorPoint(cc.p(0, 1))
    progress:setPosition(display.left, display.top)

    self.progress = progress

    self:getParent():addChild(progress)

end

function Player:setHealth(health)
    self.currentHealth = health
    if self.currentHealth > 100 then
        self.currentHealth = 100
    end
    self.progress.fill:setPercentage(self.currentHealth / self.maxHealth * 100)
end

function Player:getHealth()

    return self.currentHealth
end


function Player:flying()
    transition.stopTarget(self)
    transition.playAnimationForever(self, display.getAnimationCache("flying"))
end

function Player:drop()
    transition.stopTarget(self)
    transition.playAnimationForever(self, display.getAnimationCache("drop"))
end


function Player:hit()

    local hit = display.newSprite()
    hit:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(hit)
    transition.playAnimationOnce(hit, display.getAnimationCache("hit"), true)
    hit:setScale(0.6)
    --audio.playSound("sound/hit.mp3")
end


function Player:die()
    transition.stopTarget(self)
    transition.playAnimationOnce(self, display.getAnimationCache("die"))
end

return Player