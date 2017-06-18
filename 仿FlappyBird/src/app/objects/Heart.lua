

local Heart = class("Heart", function()

    return display.newSprite("image/heart.png")
end)

local MATERIAL_DEFAULT = cc.PhysicsMaterial(0, 0, 0)

function Heart:ctor(x, y)
    local body = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT, cc.p(0, 0))
    body:setGravityEnable(false)
    body:setDynamic(false)

    body:setCategoryBitmask(0x1000)
    body:setContactTestBitmask(0x1000)
    body:setCollisionBitmask(0x1000)
    
    self:setPhysicsBody(body)
    self:setTag(HEART_TAG)

    self:setPosition(x, y)
end


return Heart