local DialogView = qy.class("DialogView", qy.tank.view.BaseDialog, "view/login/DialogView")


function DialogView:ctor(desc,callBack,desc2)
    DialogView.super.ctor(self)
    self.isCanceledOnTouchOutside = false
    self:InjectView("des")
    local index = 1
    local maxIndex = 1
    if desc2 then
        maxIndex = 2
    end

    self:OnClickForBuilding("pannel", function(sender)
        if index < maxIndex then
            index = index+1
            self.des:setString(desc2)
        else
            callBack()   
            self:dismiss()
        end
        
    end)

    self:init(desc)
end

function DialogView:init(desc)
    self.des:setString(desc)
end

return DialogView