local AnnounceView = qy.class("AnnounceView", qy.tank.view.BaseDialog, "view/home/AnnounceView")

function AnnounceView:ctor(data)
    AnnounceView.super.ctor(self)
    --print('2343242343243',#data)
    self.isCanceledOnTouchOutside = true
	  self:OnClick("exit", function(sender)
    	self:dismiss()
    end)
    self:AnnounceView(data)
end

function AnnounceView:AnnounceView(data)
    self:InjectView("scrollView")
    self.scrollView:setScrollBarEnabled(false)--隐藏滚动条
    local height = 0
    local text = nil
    data = {'优化玩家英雄列表',
    '修复探索者释放技能后摇的连贯性',
    '游戏环境净化',
    '新增部分英雄技能buff'}  
    for i= 1, #data do
        text = ccui.Text:create()
        text:setFontName("Resources/font/ttf/black_body_2.TTF")
        text:setFontSize(18)
        text:setColor(cc.c3b(252, 254, 228))
        text:enableShadow(cc.c3b(0, 0, 0), cc.size(1, -2))
        text:enableOutline(cc.c3b(0, 0, 0), 1)
        --text:setString('i '..data[i].content)
        text:setString(i..' '..data[i])
        --text:setPosition(10,150)
        --fushuxing:setTextHorizontalAlignment(2)
        text:setAnchorPoint(0,1)
        text:setTextAreaSize(cc.size(580,44))
        self.scrollView:addChild(text,1,i)
        --print('4354353453454',text:getContentSize().height)
        height = height + text:getContentSize().height
    end
    --print('111111111111',height)
    if height > 380 then
        self.scrollView:setInnerContainerSize(cc.size(600,height))
    else
        height = 380
        self.scrollView:setInnerContainerSize(cc.size(330,380))
    end
    for i= 1, #data do
        local tag = self.scrollView:getChildByTag(i)
        if tag then
           tag:setPosition(10,height - 44 * (i-1)-5)
        end
    end
end

return AnnounceView