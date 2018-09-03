--[[
    战斗请求服务
]]

local EquipService = qy.class("EquipService", qy.tank.service.BaseService)
--入口
function EquipService:equip(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "Hero.changeEquip",
        ["p"] = data
    }))
    :send(function(response, request)
        
        callback()
    end)
end

function EquipService:sellEquip(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "equip.sell",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.QYPlaySound.playEffect("sound/chushouzhuangbei.mp3")
        local coinData = response.data.award
        local coinNum = 0
        for k, v in pairs(coinData) do
            coinNum = coinNum + coinData[k].num
        end
        qy.hint:show(qy.TextUtil:substitute('get_gold')..coinNum)
        callback()
    end)
end

function EquipService:lockEquip(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "equip.lock",
        ["p"] = data
    }))
    :send(function(response, request)
        
        qy.hint:show(qy.TextUtil:substitute('locked_equipment'))
        callback()
    end)
end

function EquipService:unlockEquip(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "equip.unlock",
        ["p"] = data
    }))
    :send(function(response, request)
        
        qy.hint:show(qy.TextUtil:substitute('cancel_locked'))
        callback()
    end)
end

function EquipService:strength(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "equip.strengthen",
        ["p"] = data
    }))
    :send(function(response, request)
        local equipData = response.data.equip
        if equipData then
            qy.QYPlaySound.playEffect("sound/qianghuachenggong.mp3")
            for k, v in pairs(equipData) do
                local equipId = equipData[k].unique_id
                local selfEquipData = {["unique_equip_id"]=equipId,['is_succeed'] = response.data.is_succeed}
                callback(selfEquipData)
            end
        else
            local selfEquipData = {['is_succeed'] = response.data.is_succeed}
            callback(selfEquipData)
        end
        
    end)
end

function EquipService:deleteHero(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "hero.delete",
        ["p"] = data
    }))
    :send(function(response, request)
        callback()
    end)
end

return EquipService
