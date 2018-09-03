require "cocos.init"
require("config")

local fileUtils = cc.FileUtils:getInstance()
fileUtils:setPopupNotify(false)
fileUtils:addSearchPath("src")
fileUtils:addSearchPath("res")
-- 屏幕适配
CC_DESIGN_RESOLUTION = {
    width = 1344,
    height = 750,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "EXACT_FIT"}
        end
    end
}

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    local message = debug.traceback(msg,3)
    qy.debuger:showBugMesg("lua error:\n\t" .. message)

    print("错误信息\nlua error:\n\t" .. message)
    print("----------------------------------------")
    return msg
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- show FPS
    cc.Director:getInstance():setDisplayStats(true)

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
    print("上边的是啥",visibleSize)
    for k,v in pairs(visibleSize) do
        print(k,v)
    end
    print("下边的是啥",origin)
    for k,v in pairs(origin) do
        print(k,v)
    end

    -- create farm
    -- local function createLayerFarm()
    --     local layerFarm = cc.Layer:create()

    --     -- add in farm background
    --     local bg = cc.Sprite:create("HelloWorld.png")
    --     bg:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2)
    --     layerFarm:addChild(bg)

    --     return layerFarm
    -- end


    -- -- run
    -- local sceneGame = cc.Scene:create()
    -- sceneGame:addChild(createLayerFarm())
    -- cc.Director:getInstance():runWithScene(sceneGame)

    require("App").new():run()
end

-- xpcall(main, __G__TRACKBACK__)
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end