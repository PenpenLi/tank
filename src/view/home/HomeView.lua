local HomeView = qy.class("HomeView", qy.tank.view.BaseView, "view/home/HomeView")

function HomeView:ctor(controller)
    print("HomeView:ctor-------------------------")
    self:InjectView("ScrollView")
    self.ScrollView:setScrollBarEnabled(false)--隐藏滚动条
    self.ScrollView:scrollToPercentBothDirection(cc.p(50,50),0.3,true)--居中显示 
end

function HomeView:guideCondition()
   
end


    

return HomeView
