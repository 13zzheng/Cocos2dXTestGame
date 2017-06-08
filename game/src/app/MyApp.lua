
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.Director:getInstance():setContentScaleFactor(640 / CONFIG_SCREEN_HEIGHT)
    display.addSpriteFrames("image/role.plist", "image/role.pvr.ccz");
    display.addSpriteFrames("image/ui.plist", "image/ui.pvr.ccz");
    display.addSpriteFrames("image/effect.plist", "image/effect.pvr.ccz");

    self:enterScene("StartScene")
end

return MyApp
