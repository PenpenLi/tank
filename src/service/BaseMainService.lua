--[[
    战斗请求服务
]]

local BaseMainService = qy.class("BaseMainService", qy.tank.service.BaseService)

function BaseMainService:level(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.baseUpgrade",
        ["p"] = data
    }))
    :send(function(response, request)
    	local arsenalInfo = response.data.building.base
        qy.BaseMainModel:update(arsenalInfo)
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        callback()
    end)
end

function BaseMainService:guide(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "guide.step",
        ["p"] = data
    }))
    :send(function(response, request)
        callback()
    end)
end

return BaseMainService
