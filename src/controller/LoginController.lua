--[[

]]
local LoginController = qy.class("LoginController", qy.tank.controller.BaseController)

function LoginController:ctor(delegate)
	print("LoginController:ctor--------------------------------")
    LoginController.super.ctor(self)

    self.viewStack = qy.tank.widget.ViewStack.new()
    self.viewStack:addTo(self)

    -- qy.UserInfoModel:init()
    -- qy.tank.model.LoginModel:init()
    
    local view = require("view.login.LoginView").new(self)
    self.viewStack:push(view)
end


-- function LoginController:showHomeView()
--     local view = require("view.game.HomeLayer").new(self)
--     self.viewStack:push(view)
-- end





return LoginController
