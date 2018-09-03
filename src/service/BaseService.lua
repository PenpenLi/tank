local BaseService = class("BaseService")

function BaseService:lookEnergy(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "user.energy",
    }))
    :send(function(response, request)
        callback(response.data.residue,response.data.next_cost)
    end)
end

function BaseService:buyEnergy(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "shop.energy",
    }))
    :send(function(response, request)
        callback()
    end)
end

function BaseService:announce(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "system.getAnnounce",
    }))
    :send(function(response, request)
        callback(response.data.announce)
    end)
end

function BaseService:formation(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "formation.lineChange",
        ["p"] = data
    }))
    :send(function(response, request)
        callback()
    end)
end

return BaseService