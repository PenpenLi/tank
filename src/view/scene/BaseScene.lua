-- local BaseScene = class("BaseScene",cc.Scene)
local BaseScene = class("BaseScene", function()
    return cc.Scene:create()
end)

function BaseScene:ctor()
print("BaseScene:ctor--------------------------------")
    self.controllerStack = qy.tank.widget.ViewStack.new()
    self.controllerStack:setLocalZOrder(5)
    self.controllerStack:addTo(self)

    self.dialogStack = qy.tank.widget.ViewStack.new()
    self.dialogStack:isRetain(true)
    self.dialogStack:setLocalZOrder(10)
    self.dialogStack:addTo(self)

    self.alertSingle = qy.tank.view.Alert.new()
    self.alertSingle:setLocalZOrder(20)
    self.alertSingle:addTo(self)

    self.hint = qy.tank.view.Hint.new()
    self.hint:setLocalZOrder(30)
    self.hint:addTo(self)


    self.loading = qy.tank.widget.ServiceLoading.new()
    self.loading:setLocalZOrder(40)
    self.loading:setVisible(false)
    self.loading:addTo(self)


    self.debuger = qy.tank.widget.Debugger.new()
    self.debuger:setLocalZOrder(60)
    self:addChild(self.debuger)


    if self.onEnter or self.enterFinish or self.onExit or self.onExitStart or self.onCleanup then
        self:registerScriptHandler(function(event)
            if event == "enter" then
                if type(self.onEnter) == "function" then
                    self:onEnter()
                end
            elseif event == "enterTransitionFinish" then
                if type(self.onEnterFinish) == "function" then
                    self:onEnterFinish()
                end
            elseif event == "exit" then
                if type(self.onExit) == "function" then
                    self:onExit()
                end
            elseif event == "exitTransitionStart" then
                if type(self.onExitStart) == "function" then
                    self:onExitStart()
                end
            elseif event == "cleanup" then
                if type(self.onCleanup) == "function" then
                    self:onCleanup()
                end
            end
        end)
    end
end

function BaseScene:push(controller)
    print("BaseScene:push--------------------------------")
    local currentController = self.controllerStack:currentView()
    if currentController and currentController.__cname == "MainController" then
        self.controllerStack:push(controller, false)
    else
        self.controllerStack:push(controller)
    end
end

function BaseScene:pop()
    print("BaseScene:pop--------------------------------")
    self.controllerStack:pop()
end

function BaseScene:replace(controller)
    print("BaseScene:replace--------------------------------")
    self.controllerStack:replace(controller)
end

function BaseScene:showDialog(dialog)
    print("BaseScene:showDialog--------------------------------")
    self.dialogStack:push(dialog)
end

function BaseScene:dismissDialog()
    print("BaseScene:dismissDialog--------------------------------")
    self.dialogStack:pop()
end

function BaseScene:disissAllDialog()
    print("BaseScene:disissAllDialog--------------------------------")
    self.dialogStack:clean()
end

function BaseScene:disissAllView()
    print("BaseScene:disissAllView--------------------------------")
    self.controllerStack:popToRoot()
end

function BaseScene:registHintAndAlert()
    print("BaseScene:registHintAndAlert--------------------------------")
    qy.alert = nil
    qy.alert = self.alertSingle
    qy.hint = nil
    qy.hint = self.hint
    qy.debuger = nil
    qy.debuger = self.debuger
end

function BaseScene:onEnter()
    print("BaseScene:onEnter--------------------------------")
    self.listener_a = qy.Event.add(qy.Event.SERVICE_LOADING_SHOW,function(event)
        print("BaseScene:push11--------------------------------")
        self.loading:setVisible(true)
        self.loading:setOpacity(0)
        self.loading:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.1, 255)))
    end)

    self.listener_b = qy.Event.add(qy.Event.SERVICE_LOADING_HIDE,function(event)
        self.loading:setVisible(false)
    end)

    qy.App.runningScene = self
    self:registHintAndAlert()

    if self.monitor then
        self.monitor:start()
    end
end

function BaseScene:onExit()
    print("BaseScene:onExit--------------------------------")
    qy.Event.remove(self.listener_a)
    qy.Event.remove(self.listener_b)

    if self.monitor then
        self.monitor:stop()
    end
end

function BaseScene:onCleanup()
    print("BaseScene:onCleanup--------------------------------")
end

return BaseScene
