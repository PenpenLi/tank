local ScenesManager = {}

function ScenesManager:instance()
    local o = _G.ScenesManager
    if o == nil then 
        o = {}
        _G.ScenesManager = o
        setmetatable(o, self)
        self.__index = self 
    end
    return o
end

function ScenesManager:start()
    print("ScenesManager:start--------------------------------")
    self:showLoginScene()
end


function ScenesManager:showLoginScene()
    print("ScenesManager:showLoginScene--------------------------------")
    self:replaceScene(qy.tank.view.scene.LoginScene.new())
end

function ScenesManager:showHomeScene()
    qy.tank.utils.cache.CachePoolUtil.removeAllArmatureFile()
    self:replaceScene(qy.tank.view.scene.HomeScene.new())
end

function ScenesManager:showDungeonScene()
    self:replaceScene(qy.tank.view.scene.DungeonScene.new())
end




function ScenesManager:popScene()
    cc.Director:getInstance():popScene()
end

function ScenesManager:pushScene(scene)
    cc.Director:getInstance():pushScene(scene)
end

function ScenesManager:replaceScene(scene)
    print("ScenesManager:replaceScene--------------------------------")
    if cc.Director:getInstance():getRunningScene() then
        print("ScenesManager:replaceScene--------------------------------替换")
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
        print("ScenesManager:replaceScene--------------------------------运行")
    end
end

function ScenesManager:getRunningScene()
    return cc.Director:getInstance():getRunningScene()
end

return ScenesManager