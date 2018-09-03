--[[

]]

local DungeonService = qy.class("DungeonService", qy.tank.service.BaseService)


--选择关卡
function DungeonService:start(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.start",
        ["p"] = {
            ["checkpoint_id"]   = params["checkpoint_id"],
            --（1=普通关卡，2=boss关卡）
            ["checkpoint_type"] = params["checkpoint_type"],
            ["difficulty"]      = params["difficulty"],
            ["form_hero"]       = params["form_hero"],
            ["supply"]          = params["supply"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--恢复之前的关卡
function DungeonService:resume(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.resume",
        ["p"] = {
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--执行探索中触发的战斗事件
function DungeonService:roomBattleStart(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.roomBattleStart",
        ["p"] = {
            ["native"]      = params["native"],
            ["room_index"]  = params["room_index"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--boss房战斗开始前事件
function DungeonService:bossBattle(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.bossBattle",
        ["p"] = {
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--执行点击事件
function DungeonService:sceneObjectTrigger(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.sceneObjectTrigger",
        ["p"] = {
            ["native"]      = params["native"],
            ["room_index"]  = params["room_index"]
        }
    }))
    :send(function(response, request)
        -- qy.DungeonModel:updatePosData()
        callback(response.data)
    end)
end


--直接战斗事件结束
function DungeonService:roomBattleEnd(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.roomBattleEnd",
        ["p"] = {
            ["native"]      = params["native"],
            ["room_index"]  = params["room_index"],
            ["formation"]   = params["formation"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end



--点击事件触发的战斗，的结束
function DungeonService:sceneObjectTail(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.sceneObjectTail",
        ["p"] = {
            ["native"]      = params["native"],
            ["room_index"]  = params["room_index"],
            ["formation"]   = params["formation"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end



--换位
function DungeonService:formationLineup(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "formation.lineup",
        ["p"] = {
            --{"1":"21","4":"31","2":"11","3":"1"}
            ["position"]      = params["position"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end





--在地图点击选择下一个房间
function DungeonService:nextRoom(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.next",
        ["p"] = {
            ["native"]      = params["native"],
            ["next"]        = params["next"],
        }
    }))
    :send(function(response, request)
        qy.DungeonModel:setData(response.data)
        callback(response.data)
    end)
end



--在漫画里点击一个选项
function DungeonService:selectEvent(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.select",
        ["p"] = {
            ["target"]      = params["target"],
            ["select_index"]= params["select_index"],
        }
    }))
    :send(function(response, request)
        qy.DungeonModel:setData(response.data)
        callback(response.data)
    end)
end


--在漫画触发的战斗结束
function DungeonService:selectBattleEnd(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.selectBattleEnd",
        ["p"] = {
            ["native"]      = params["native"],
            ["formation"]   = params["formation"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--使用扎营技能
function DungeonService:encampSkill(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.campSkill",
        ["p"] = {
            ["native"]          = params["native"],
            ["hero_unique_id"]  = params["hero_unique_id"],
            ["invest"]          = params["invest"],
            ["index"]           = params["index"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end

--使用补给道具
function DungeonService:useSupply(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "props.useSupply",
        ["p"] = {
            ["supply_id"]       = params["supply_id"],
            ["invest"]          = params["invest"],
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end



--扎营结束，判断是否触发战斗
function DungeonService:encampBattle(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.campBattle",
        ["p"] = {
            ["native"]          = params["native"],
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--扎营触发战斗， 战斗结束
function DungeonService:encampBattleEnd(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.campBattleEnd",
        ["p"] = {
            ["native"]      = params["native"],
            ["formation"]   = params["formation"]
        }
    }))
    :send(function(response, request)
        callback(response.data)
    end)
end


--黑市
function DungeonService:blackMarket(params, callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.blackMarket",
        ["p"] = {
            ["native"]      = params["native"],
            ["market"]      = params["market"]
        }
    }))
    :send(function(response, request)
        require("view/common/AwardTipFrame").new(response.data.award):show()
        callback(response.data)
    end)
end


--关卡结算
function DungeonService:closure(params)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "explore.closure",
        ["p"] = {
            ["formation"]   = params["formation"]
        }
    }))
    :send(function(response, request)
        if response.data.is_win == false then
            require("view.dungeon.settlement.SettlementLoseDialog").new(response.data):show()
        else
            require("view.dungeon.settlement.SettlementWinDialog1").new(response.data):show()
        end
        -- qy.DungeonModel:clearData()
        -- qy.BattleBodyModel:clearData()
    end)
end



return DungeonService
