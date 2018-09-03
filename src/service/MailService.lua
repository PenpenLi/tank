--[[
    战斗请求服务
]]

local MailService = qy.class("MailService", qy.tank.service.BaseService)
--入口
function MailService:getMailList(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mail.getlist",
        ["p"] = data
    }))
    :send(function(response, request)
        local maillist = response.data.list
        qy.MailModel:init(maillist)
        callback()
    end)
end

function MailService:close(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mail.close",
        ["p"] = data
    }))
    :send(function(response, request)
        callback()
    end)
end

function MailService:read(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mail.readed",
        ["p"] = data
    }))
    :send(function(response, request)
       local status = response.data.status
        callback(status)
    end)
end

function MailService:receive(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "mail.gain",
        ["p"] = data
    }))
    :send(function(response, request)
        require("view/common/AwardTipFrame").new(response.data.award):show()
       local status = response.data.result
        callback(status)
    end)
end

return MailService
