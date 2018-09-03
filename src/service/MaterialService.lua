--[[
    战斗请求服务
]]

local MaterialService = qy.class("MaterialService", qy.tank.service.BaseService)

function MaterialService:level(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.materialUpgrade",
        ["p"] = data
    }))
    :send(function(response, request)
    	local arsenalInfo = response.data.building.material
        qy.MaterialModel:update(arsenalInfo)
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        callback()
    end)
end

return MaterialService
