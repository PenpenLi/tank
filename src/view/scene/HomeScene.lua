local HomeScene = qy.class("HomeScene", qy.tank.view.scene.BaseScene)


function HomeScene:ctor()
    print("HomeScene ctor")
    HomeScene.super.ctor(self)
    -- 特殊表, 在表里的Controller都使用push提交
    self._pushControllers = {
        ["PetController"] = true,
        ["LineupController"] = true
    }
    --self:createWithPhysics()
    -- 启动主控制器

    self:push(qy.tank.controller.HomeController.new())
end

function HomeScene:push(controller)
    local cName = controller.__cname

    -- 如果当前只有1个Controller, 使用push的方式
    if self.controllerStack:size() == 1 or self._pushControllers[cName]==nil then
        HomeScene.super.push(self, controller)
    else
        HomeScene.super.replace(self, controller)
    end
end

function HomeScene:pop()
    HomeScene.super.pop(self)
    -- 可能被执行了finish
    local currentController = self.controllerStack:currentView()
end

function HomeScene:onEnter()
    print("HomeScene enter")
    -- print()
    qy.QYPlaySound.playMusic("music/chengnei.mp3",true)
    HomeScene.super.onEnter(self)

end

function HomeScene:onExit()
    print("HomeScene exit")
    HomeScene.super.onExit(self)

end

function HomeScene:onCleanup()
    print("HomeScene cleanup")
    HomeScene.super.onCleanup(self)


end

return HomeScene
