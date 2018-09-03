--[[
说明: 提示小浮层
作者: 林国锋
日期: 2014-12-23

usage:
qy.Widget.Toast：make("内容", 1, cc.p(480, 320)):show()
]]

local Toast = qy.class("Toast", qy.tank.view.BaseView, "widget/Toast")

function Toast:ctor(delegate)
    Toast.super.ctor(self)

    self.delegate = delegate
    self:InjectView("bg")
    self:InjectView("Text_title")
end


-- title: 显示的内容
-- duration: 显示多长时间, 默认为1.5秒
-- position: 在屏幕的位置, 默认屏幕中心
function Toast:make(toast_ , title, position)
    local toast = toast_
    toast.Text_title:setString(tostring(title))

    local size = toast.Text_title:getContentSize()

    self.p = position or cc.p(qy.winSize.width / 2, qy.winSize.height * 0.6)
    toast:setPosition(self.p.x, self.p.y)

    return toast
end


return Toast