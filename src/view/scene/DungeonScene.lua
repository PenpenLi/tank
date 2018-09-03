local DungeonScene = qy.class("DungeonScene", qy.tank.view.scene.BaseScene)


function DungeonScene:ctor()
    print("DungeonScene ctor")
    DungeonScene.super.ctor(self)
    -- 特殊表, 在表里的Controller都使用push提交
    self._pushControllers = {
        ["PetController"] = true,
        ["LineupController"] = true
    }
    --self:createWithPhysics()
    -- 启动主控制器

    -- self:push(qy.tank.controller.DungeonController.new())
    
    qy.QYPlaySound.playMusic("music/tansuozhong.mp3")
    

    qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/fx/".. qy.language .."/battle/fight",nil)
    for i = 1, 22 do
        qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/fx/".. qy.language .."/battle/hit"..i,nil)
    end
    qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/fx/".. qy.language .."/battle/touxi",nil)
    qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/fx/".. qy.language .."/battle/xuanyun",nil)
    qy.tank.utils.cache.CachePoolUtil.addArmatureFileAsync("dragonBone/fx/".. qy.language .."/battle/Fear",nil)


end

function DungeonScene:push(controller)
    local cName = controller.__cname

    -- 如果当前只有1个Controller, 使用push的方式
    if self.controllerStack:size() == 1 or self._pushControllers[cName]==nil then
        DungeonScene.super.push(self, controller)
    else
        DungeonScene.super.replace(self, controller)
    end
end

function DungeonScene:pop()
    DungeonScene.super.pop(self)
    -- 可能被执行了finish
    local currentController = self.controllerStack:currentView()
end

function DungeonScene:onEnter()
    print("DungeonScene enter")
    DungeonScene.super.onEnter(self)

    self:push(qy.tank.controller.DungeonController.new())
end

function DungeonScene:onExit()
    print("DungeonScene exit")
    DungeonScene.super.onExit(self)
end

function DungeonScene:onCleanup()
    print("DungeonScene cleanup")
    DungeonScene.super.onCleanup(self)
end

return DungeonScene
