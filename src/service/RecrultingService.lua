--[[
    战斗请求服务
]]

local RecrultingService = qy.class("RecrultingService", qy.tank.service.BaseService)

local model =  qy.tank.model.RecruitModel
--入口
function RecrultingService:lottery(type,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "recruit.exchange",
        ["p"] = type
    }))
    :send(function(response, request)
        qy.tank.model.RecruitModel:init(response.data)
        qy.Event.dispatch("updateTips")
        callback()
    end)
end

function RecrultingService:recruit(type,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "recruit.acceptance",
        ["p"] = type
    }))
    :send(function(response, request)
        qy.tank.model.RecruitModel:setAwait(response.data.await)

        callback()
    end)
end

return RecrultingService
