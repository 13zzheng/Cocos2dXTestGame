

local Airship = class("Airship", function()
    return display.newSprite("#airship.png")
end)

local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.0, 0.0, 0.0) 

function Airship:ctor(x, y)
    local body = cc.PhysicsBody:createBox(self:getContentSize(), MATERIAL_DEFAULT, cc.p(0, 0))
    body:setGravityEnable(false)
    body:setRotationEnable(false)

    body:setCategoryBitmask(0x1000)
    body:setContactTestBitmask(0x0100)
    body:setCollisionBitmask(0x0001)

    self:setPhysicsBody(body)
    self:setTag(AIRSHIP_TAG)
    
    self:setPosition(x, y)

    local moveUp = cc.MoveBy:create(3, cc.p(0, self:getContentSize().height / 2))
    local moveDown = cc.MoveBy:create(3, cc.p(0, -self:getContentSize().height / 2))
    local sequence = cc.Sequence:create(moveUp, moveDown)

    self:runAction(cc.RepeatForever:create(sequence))

end



return Airship