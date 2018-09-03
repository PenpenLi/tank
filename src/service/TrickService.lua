--[[
    战斗请求服务
]]

local TrickService = qy.class("TrickService", qy.tank.service.BaseService)
--入口
function TrickService:zhiliao(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "hero.treatQuirks",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.hint:show(qy.TextUtil:substitute("quirks_delete1"))
        callback()
    end)
end

function TrickService:lock(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "hero.lockQuirks",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.hint:show(qy.TextUtil:substitute("quirks_delete2"))
        callback()
    end)
end

function TrickService:unlock(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "hero.unLockQuirks",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.hint:show(qy.TextUtil:substitute("quirks_delete3"))
        callback()
    end)
end

return TrickService
