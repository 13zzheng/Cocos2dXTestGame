
local Heart = require("app.objects.Heart")
local Airship = require("app.objects.Airship")
local Bird = require("app.objects.Bird")

local BackgroundLayer = class("BackgroundLayer", function()
    return display.newLayer()
end)

function BackgroundLayer:ctor()
    self.distanceBg = {}
    self.closeBg = {}
    self.birds = {}
    self.distanceScrollSpeed = 50
    self.closeScrollSpeed = 80
    self.TMXScrollSpeed= 130

    self:createBackground()
    self:addEdgeSegment()
    self:addObjects("heart", Heart)
    self:addObjects("airship", Airship)
    self:addObjects("bird", Bird)

end

function BackgroundLayer:startGame()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
    self:scheduleUpdate()
end

function BackgroundLayer:createBackground()

    -- 添加最底层的静态背景图
    local staticBg = display.newSprite("image/bj1.jpg", display.cx, display.cy)
        :addTo(self, -4)
    
    -- 添加缓慢移动的远景图
    local distanceBg1 = display.newSprite("image/b2.png")
        :align(display.BOTTOM_LEFT, display.left, display.bottom + 10)
        :addTo(self, -3)
    local distanceBg2 = display.newSprite("image/b2.png")
        :align(display.BOTTOM_LEFT, display.left + distanceBg1:getContentSize().width, display.bottom + 10)
        :addTo(self, -3)

    table.insert( self.distanceBg, distanceBg1 )
    table.insert( self.distanceBg, distanceBg2 )

    -- 添加快速移动的近景图
    local closeBg1 = display.newSprite("image/b1.png")
        :align(display.BOTTOM_LEFT, display.left, display.bottom)
        :addTo(self, -2)
    local closeBg2 = display.newSprite("image/b1.png")
        :align(display.BOTTOM_LEFT, display.left + closeBg1:getContentSize().width, display.bottom)
        :addTo(self, -2)

    table.insert(self.closeBg, closeBg1)
    table.insert(self.closeBg, closeBg2)

    -- 添加TMX背景

    self.map = cc.TMXTiledMap:create("image/map.tmx")
        :align(display.BOTTOM_LEFT, display.left, display.bottom)
        :addTo(self, -1)
    
end


function BackgroundLayer:scrollBackgrounds(dt)
    -- 循环移动远景
    if self.distanceBg[2]:getPositionX() <= 0 then
        self.distanceBg[1]:setPositionX(0)
    end

    local x1 = self.distanceBg[1]:getPositionX() - dt*self.distanceScrollSpeed
    local x2 = x1 + self.distanceBg[1]:getContentSize().width

    self.distanceBg[1]:setPositionX(x1)
    self.distanceBg[2]:setPositionX(x2)

    -- 循环移动近景
    if self.closeBg[2]:getPositionX() <= 0 then
        self.closeBg[1]:setPositionX(0)
    end

    local x1 = self.closeBg[1]:getPositionX() - dt*self.closeScrollSpeed
    local x2 = x1 + self.closeBg[1]:getContentSize().width

    self.closeBg[1]:setPositionX(x1)
    self.closeBg[2]:setPositionX(x2)

    -- 移动TMX背景
    if self.map:getPositionX()  <= display.width - self.map:getContentSize().width then
        self:unscheduleUpdate()
    end

    local x = self.map:getPositionX() - dt*self.TMXScrollSpeed
    self.map:setPositionX(x)


end

function BackgroundLayer:update(dt)
    self:scrollBackgrounds(dt)
    self:addVelocityToBird()
end

function BackgroundLayer:addEdgeSegment()
    local width = display.width
    local height1 = display.height
    local height2 = display.height *3/16

    -- 添加上边界
    local top = display.newNode()
    local topBody = cc.PhysicsBody:createEdgeSegment(cc.p(0, height1), cc.p(width, height1))
    top:setPhysicsBody(topBody)

    topBody:setCategoryBitmask(0x1001)
    topBody:setContactTestBitmask(0x0010)
    topBody:setCollisionBitmask(0x1000)

    top:setTag(GROUND_TAG)
    self:addChild(top)

    -- 添加下边界
    local bottom = display.newNode()
    local bottomBody = cc.PhysicsBody:createEdgeSegment(cc.p(0, height2), cc.p(width, height2))
    bottom:setPhysicsBody(bottomBody)

    bottomBody:setCategoryBitmask(0x1000)
    bottomBody:setContactTestBitmask(0x0010)
    bottomBody:setCollisionBitmask(0x1000)

    bottom:setTag(GROUND_TAG)
    self:addChild(bottom)
end

function BackgroundLayer:addObjects(objectGroupName, class)
    local objects = self.map:getObjectGroup(objectGroupName):getObjects()

    local dict = nil

    for i=1,#objects do
        dict = objects[i]
        if dict == nil then
            break
        end

        local x = dict["x"]
        local y = dict["y"]

        local object = class.new(x, y)
        self.map:addChild(object)
        if objectGroupName == "bird" then
            table.insert(self.birds, object)
        end
    end
end

function BackgroundLayer:addVelocityToBird()
    local dict = nil

    for i=1,#self.birds do
        dict = self.birds[i]
        if dict == nil then
            break
        end

        if dict:getPositionX() <= display.width - self.map:getPositionX() then
            
            if dict:getPhysicsBody():getVelocity().x == 0 then
                dict:getPhysicsBody():setVelocity(cc.p(-70, math.random(-40, 40)))
            else
                table.remove( self.birds, i)
            end
        end
    end

end



return BackgroundLayer