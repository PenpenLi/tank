local LoginScene = qy.class("LoginScene", qy.tank.view.scene.BaseScene)


function LoginScene:ctor()
    print("LoginScene:ctor--------------------------------")
    LoginScene.super.ctor(self)
    -- 特殊表, 在表里的Controller都使用push提交
    self._pushControllers = {
        ["PetController"] = true,
        ["LineupController"] = true
    }
    --self:createWithPhysics()
    -- 启动主控制器

    self:push(qy.tank.controller.LoginController.new())
end

function LoginScene:push(controller)
    print("LoginScene:push--------------------------------")
    local cName = controller.__cname

    -- 如果当前只有1个Controller, 使用push的方式
    if self.controllerStack:size() == 1 or self._pushControllers[cName]==nil then
        LoginScene.super.push(self, controller)
    else
        LoginScene.super.replace(self, controller)
    end
end

function LoginScene:pop()
    LoginScene.super.pop(self)
    -- 可能被执行了finish
    local currentController = self.controllerStack:currentView()
end

function LoginScene:onEnter()
    print("LoginScene enter")
    -- print()
    LoginScene.super.onEnter(self)

end

function LoginScene:onExit()
    print("LoginScene exit")
    LoginScene.super.onExit(self)

end

function LoginScene:onCleanup()
    print("LoginScene cleanup")
    LoginScene.super.onCleanup(self)

end

return LoginScene
