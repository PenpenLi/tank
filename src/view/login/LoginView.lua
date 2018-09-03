local LoginView = qy.class("LoginView", qy.tank.view.BaseView, "view/login/LoginView")

function LoginView:ctor(delegate)
    LoginView.super.ctor(self)
    print("LoginView:ctor----------------------------------")
    self.delegate = delegate

    self:InjectView("yan1")
    self:InjectView("yan2")
    self:InjectView("yan3")
    self:InjectView("yan4")
    self:InjectView("BtnEnterGame")
    self:InjectView("TextUserName")
    self:InjectView("userNameBg")
    self:InjectView("guestLogin")   

    local x = 1
    self:OnClick("guestLogin", function()
        print("游戏点击登录")
        qy.tank.utils.QYSDK.visitorLogin(2,function (  )
            --游客登陆成功，LoginModel中已经记录用户id信息
            self.BtnEnterGame:setVisible(true)
            self.userNameBg:setVisible(true)
             self.guestLogin:setVisible(false)
            local _nickname = qy.tank.model.LoginModel:getPlayerInfoEntity().platform_user_id
            self.TextUserName:setString("玩家：".._nickname)
        end,function (  )
            print("游客登录失败")
        end)
        -- local myScene = require("src/view/home/HomeView").new()
        -- local sceneGame = cc.Scene:create()
        -- sceneGame:addChild(myScene)
        -- cc.Director:getInstance():replaceScene(cc.TransitionFade:create(0.5, sceneGame, cc.c4b(255,255,255,255)))
        
        -- cc.Director:getInstance():replaceScene(cc.TransitionFlipX:create(2, sceneGame))
        -- cc.Director:getInstance():replaceScene(cc.TransitionSlideInT:create(2, sceneGame))

    end)


   

end




return LoginView
