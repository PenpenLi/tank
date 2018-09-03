--[[
    战斗请求服务
]]

local ArsenalService = qy.class("ArsenalService", qy.tank.service.BaseService)
--入口
function ArsenalService:login(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.arsenalInfo",
        ["p"] = nil
    }))
    :send(function(response, request)
    	--local arsenalInfo = response.data.arsenal
        if response.data.arsenal then
            local arsenalInfo = response.data.building.arsenal
            qy.ArsenalModel:update(arsenalInfo)
        end
        callback()
    end)
end

function ArsenalService:level(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.arsenalUpgrade",
        ["p"] = data
    }))
    :send(function(response, request)
    	local arsenalInfo = response.data.building.arsenal
        qy.ArsenalModel:update(arsenalInfo)
        qy.Event.dispatch("refreshWeaponNum")
        qy.Event.dispatch("refreshWeaponLevel")
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        callback()
    end)
end

function ArsenalService:buy(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.arsenalPurchase",
        ["p"] = data
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.arsenal
        qy.ArsenalModel:update(arsenalInfo)
        require("view/common/AwardTipFrame").new(response.data.award):show()
        callback()
    end)
end

function ArsenalService:weaponBox(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.arsenalBox",
        ["p"] = nil
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.arsenal
        qy.ArsenalModel:update(arsenalInfo)
        require("view/common/AwardTipFrame").new(response.data.award):show()
        qy.Event.dispatch("updateTips")
        callback()
    end)
end

function ArsenalService:refresh(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "building.arsenalVary",
        ["p"] = nil
    }))
    :send(function(response, request)
        local arsenalInfo = response.data.building.arsenal
        qy.ArsenalModel:update(arsenalInfo)
        callback()
    end)
end
return ArsenalService
