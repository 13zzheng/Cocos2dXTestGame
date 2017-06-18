

local Bird = class("Bird", function()
    return display.newSprite("#bird1.png")
end)

local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.0, 0.0, 0.0) 

function Bird:ctor(x, y)
    local body = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT, cc.p(0, 0))
    body:setGravityEnable(false)
    body:setRotationEnable(false)

    body:setCategoryBitmask(0x1000)
    body:setContactTestBitmask(0x0100)
    body:setCollisionBitmask(0x0001)

    self:setPhysicsBody(body)
    self:setTag(BIRD_TAG)

    self:setPosition(x, y)

    transition.playAnimationForever(self, display.getAnimationCache("bird"))

end




return Bird