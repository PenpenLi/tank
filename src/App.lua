--[[
    Description:全局启动类
    Author: Aaron Wei
    Date: 2015-01-07 18:00:16
]]

require("utils.functions")
require("utils.MemoryScan")
require("utils.co") -- import co, yield


function qy.class(classname, super, theme)
    local cls = class(classname, super)
    if type(theme) == "string" then
        cls.__create = function()
            return cls.super.__create(theme)
        end
    end
    return cls
end

local App = class("App")

function App:ctor()
    print("App:ctor----------------------------------")
    self:registerClass()
    local viewsize = cc.Director:getInstance():getWinSize()

    qy.App = self
    qy.Event = qy.tank.utils.EventUtil
    qy.Timer = qy.tank.utils.TimerUtil
    qy.Runtime = qy.tank.utils.Runtime
    qy.Runtime.start()
    qy.Utils = require("utils.Utils")
    qy.Http = require("utils.Http")
    qy.json = require("utils.dkjson")
    -- qy.json = qy.tank.utils.dkjson
    qy.M = require("utils.QYPlaySound")
    qy.winSize = {width = viewsize.width, height = viewsize.height}
    print("啥玩意啊",qy.winSize)

    qy.LoginConfig = qy.tank.config.LoginConfig
    qy.Analytics = qy.tank.utils.Analytics
    qy.TextUtil = qy.tank.utils.TextUtil
    end

-- 动态注册类,类java语法调用,包路径首字母小写,类名首字母大写
-- local login = qy.tank.scene.LoginScene.new()
function App:registerClass()
    print("App:registerClass----------------------------------")
    local o = {}
    local recursion; function recursion(_o)
        setmetatable(_o, {
            __index = function(t, k)
                local path = rawget(t,"__path")
                local t1 = nil
                if string.byte(k,1) == string.byte(string.upper(k),1) then
                    local className
                     if path then
                        className = path.."."..k
                    else
                        className = k
                    end
                    -- print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>className",className)
                    t1 = require(className)
                    rawset(t, k, t1)
                else
                    t1 = {}
                    if path then
                        t1.__path = path ..".".. k
                    else
                        t1.__path = k
                    end
                    -- print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>path",t1.__path)
                    rawset(t, k, t1)
                    recursion(_o[k])
                end
                return t1
            end,

            __newindex = function(_, k, v)
                -- only read
            end,
        })
    end

    recursion(o)
    qy.tank = o
end

-- 监听键盘事件
function App:registerKeyboardListener()
    -- local keyTime = 0
    -- local listener = cc.EventListenerKeyboard:create()
    -- listener:registerScriptHandler(function(keyCode, event)
    --     if keyCode == cc.KeyCode.KEY_BACK then
    --         if (os.time() - keyTime) > 1.5 then
    --             keyTime = os.time()
    --             if tolua.cast(qy.hint,"cc.Node") then
    --                 local sdk = qy.tank.utils.SDK
    --                 sdk:exitgame()
    
    --             end
    --         else
    --             qy.Analytics:doAction("onExitGame")
    --         end
    --     end
    -- end, cc.Handler.EVENT_KEYBOARD_RELEASED)

    -- local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    -- eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

    -- -- 监听游戏进出后台
    -- if not self.listener1 then
    --     self.listener1 = cc.EventListenerCustom:create("event_come_to_background1",function()
    --         self.time = os.time()
    --         print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> App event_come_to_background1",self.time)
    --     end)
    --     cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener1,1)
    -- end

    -- if not self.listener2 then
    --     self.listener2 = cc.EventListenerCustom:create("event_come_to_foreground1",function()
    --         if self.time then
    --             local t = os.time() - self.time
    --             print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> App event_come_to_foreground1",t)
    --             -- if t >= 3 then
    --             --     qy.tank.manager.ScenesManager:showLoginScene()
    --             -- end
    --         end
    --     end)
    --     cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener2,1)
    -- end
end

function App:start()
    print("App:start----------------------------------")
    self:registerKeyboardListener()
    qy.tank.manager.ScenesManager:start()


    -- local myScene = require("src/view/login/LoginView")
    -- local myScene = qy.tank.view.login.LoginView.new()
    -- local sceneGame = cc.Scene:create()
    -- sceneGame:addChild(myScene)
    -- cc.Director:getInstance():runWithScene(sceneGame)
end


function App:run()
    print("App:run----------------------------------")
    math.newrandomseed()
    self:start()
end

return App
