--[[
]]
local RecruitingController = qy.class("RecruitingController", qy.tank.controller.BaseController)

function RecruitingController:ctor(delegate)
    RecruitingController.super.ctor(self)

    self.viewStack = qy.tank.widget.ViewStack.new()
    self.viewStack:addTo(self)
    print("RecruitingController")
    local view = require("view.recruiting.RecrultingView").new(self)
    self.viewStack:push(view)
end

function RecruitingController:cleanController()
     self:finish();
end

-- function HomeController:showHomeView()
--     local view = require("view.game.HomeLayer").new(self)
--     self.viewStack:push(view)
-- end




return RecruitingController
