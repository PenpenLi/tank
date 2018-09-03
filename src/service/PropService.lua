--[[
    战斗请求服务
]]

local PropService = qy.class("PropService", qy.tank.service.BaseService)
--入口
function PropService:use(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "item.useProp",
        ["p"] = data
    }))
    :send(function(response, request)
    	if response.data.award then
            qy.QYPlaySound.playEffect("sound/kaixiangzi.mp3")
    		require("view/common/AwardTipFrame").new(response.data.award):show()
    	else
    		qy.hint:show('空空如也')
    	end
        callback()
    end)
end
return PropService
