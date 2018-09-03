--[[
    CG片头
    Author: H.X.Sun 
    Date：2015-11-06
]]

local CGView = class("CGView", qy.tank.view.BaseDialog)

local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename("res/video/cg_haven.mp4")

function CGView:ctor()
    CGView.super.ctor(self)
    local ColorLayer = cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild(ColorLayer)

    --self.sceneTransition = qy.tank.widget.SceneTransition.new()
    --self.sceneTransition:setVisible(false)
    --self:addChild(self.sceneTransition, 10)

    self.videoPlayer = ccexp.VideoPlayer:create()
    self.videoPlayer:setPosition(qy.centrePoint)
    self.videoPlayer:setAnchorPoint(0.5,0.5)
    self.videoPlayer:setContentSize(qy.winSize)
    self.videoPlayer:setFileName(videoFullPath)
    self.videoPlayer:setKeepAspectRatioEnabled(true)
    --self.videoPlayer:addSkipButton()
    -- self.videoPlayer:setFullScreenEnabled(true)
    -- self.videoPlayer:play()
    self.videoPlayer:setVisible(true)

    self.videoPlayer:addEventListener(function(sener, eventType)
        if eventType == 3 then
            self:onCompleted()
        end
    end)

    self:addChild(self.videoPlayer,999)
    self.videoPlayer:play()

    --self.skip = ccui.ImageView:create()
    --self.skip:loadTexture("Resources/hero/7.png")
    --self.skip:setPosition(qy.winSize.width / 2, 130)
    --self:addChild(self.skip,999)
    --require("view.home.DescribeView").new("clinic","clinic_desc"):show()
end

function CGView:onCompleted()
     self.videoPlayer:stop();
    --[[if self.videoPlayer then
        self.videoPlayer:stop();
        self.videoPlayer:removeFromParent(true);
        self.videoPlayer = nil
    end--]]
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        self.videoPlayer:getParent():removeChild(self.videoPlayer)
        print("PLATFORM_OS_ANDROID self.removeChild:stop()===================>>>>>>>")
    end
    qy.tank.manager.ScenesManager:showHomeScene()
end

return CGView