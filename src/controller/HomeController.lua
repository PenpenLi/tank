--[[
]]
local HomeController = qy.class("HomeController", qy.tank.controller.BaseController)

function HomeController:ctor(delegate)
    HomeController.super.ctor(self)

    self.viewStack = qy.tank.widget.ViewStack.new()
    self.viewStack:addTo(self)
    print("HomeController")
    local view = require("view.home.HomeView").new(self)
    self.viewStack:push(view)
end


-- function HomeController:showHomeView()
--     local view = require("view.game.HomeLayer").new(self)
--     self.viewStack:push(view)
-- end

function HomeController:openSelectDungeonView()
    local view = require("view.select_dungeon.SelectDungeonLayer").new(self)
    self.viewStack:push(view)
end

function HomeController:openBuySupplyView(data, shopid)
    local view = require("view.buy_supply.BuySupplyLayer").new(self, data)
    view:init(shopid)
    self.viewStack:push(view)
end

function HomeController:openSelectBossView()
    local view = require("view.select_dungeon.SelectBossDialog").new(self)
    self.viewStack:push(view)
end


function HomeController:popView()
	self.viewStack:pop()
end


return HomeController
