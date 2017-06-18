
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("src/app/scenes")
    cc.Director:getInstance():setContentScaleFactor(640 / CONFIG_SCREEN_HEIGHT)
    math.randomseed(os.time())
    display.addSpriteFrames("image/player.plist", "image/player.pvr.ccz")
    audio.preloadMusic("sound/background.mp3")
    audio.preloadSound("sound/button.wav")
    audio.preloadSound("sound/ground.mp3")
    audio.preloadSound("sound/heart.mp3")
    audio.preloadSound("sound/hit.mp3")
    self:enterScene("MainScene")
end

return MyApp
