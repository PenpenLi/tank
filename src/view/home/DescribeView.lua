local DescribeView = qy.class("DescribeView", qy.tank.view.BaseDialog, "view/home/DescribeView")

function DescribeView:ctor(title,des)
    DescribeView.super.ctor(self)
    self.isCanceledOnTouchOutside = true
	  self:OnClick("exit", function(sender)
    	self:dismiss()
    end)
    self:initView(title,des)
end

function DescribeView:initView(title,des)
    self:InjectView("title")
    self:InjectView("des")
    self.title:setString(qy.TextUtil:substitute(title))
    self.des:setString(qy.TextUtil:substitute(des))
end

return DescribeView