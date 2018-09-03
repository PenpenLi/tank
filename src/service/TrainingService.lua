--[[
    战斗请求服务
]]

local TrainingService = qy.class("TrainingService", qy.tank.service.BaseService)
--入口
function TrainingService:login(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.trainingInfo",
        ["p"] = nil
    }))
    :send(function(response, request)
        if response.data.building then
            local arsenalInfo = response.data.building.training
            qy.TrainingModel:update(arsenalInfo)
        end
    	--local arsenalInfo = response.data.arsenal
        callback()
    end)
end

function TrainingService:level(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.trainingUpgrade",
        ["p"] = data
    }))
    :send(function(response, request)
    	local arsenalInfo = response.data.building.training
        qy.TrainingModel:update(arsenalInfo)
        qy.Event.dispatch("refreshSkillNum")
        qy.Event.dispatch("refreshSkillLevel")
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        callback()
    end)
end

function TrainingService:buy(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.trainingPurchase",
        ["p"] = data
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.training
        qy.TrainingModel:update(arsenalInfo)
        qy.hint:show(qy.TextUtil:substitute("success_trade"))
        callback()
    end)
end

function TrainingService:weaponBox(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.trainingBox",
        ["p"] = nil
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.training
        qy.TrainingModel:update(arsenalInfo)
        require("view/common/AwardTipFrame").new(response.data.award):show()
        qy.Event.dispatch("updateTips")
        callback()
    end)
end

function TrainingService:refresh(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.trainingVary",
        ["p"] = nil
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.training
        qy.TrainingModel:update(arsenalInfo)
        callback()
    end)
end
return TrainingService
