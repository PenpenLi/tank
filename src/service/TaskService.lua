--[[
    战斗请求服务
]]

local TaskService = qy.class("TaskService", qy.tank.service.BaseService)
--入口
function TaskService:receive(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mission.finish",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.QYPlaySound.playEffect("sound/renwuwancheng.mp3")
        require("view/common/AwardTipFrame").new(response.data.award):show()
        qy.Event.dispatch("updateTips")
        callback()
    end)
end

function TaskService:login(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mission.info",
    }))
    :send(function(response, request)
        if response.data.mission then
            qy.TaskModel:update(jdata.mission)
        end
        callback()
    end)
end

return TaskService
