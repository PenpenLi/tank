--[[--
--tip util 用于生成一个tip
--Author: H.X.Sun
--Date: 2015-05-21
--]]

local TipUtil = {}

--[[--
--创建tip内容
--]]
function TipUtil.createTipContent(params)
    local tip = nil
    local awardType = qy.tank.view.type.AwardType
    if params.type == awardType.TANK then
        --战车
        local entity = nil 
        if type(params.entity) == "table" then
            entity = params.entity
        else
            -- print("params.entity ===" .. qy.json.encode(params.entity))
            entity = qy.tank.entity.TankEntity.new(params.entity)
        end
        tip = qy.tank.view.tip.TankTip.new(entity)
    elseif params.type == awardType.EQUIP or params.type == awardType.EQUIP_FRAGMENT then
        --装备或装备碎片
         local entity = params.entity
        tip = qy.tank.view.tip.EquipTip.new(entity, params.type)
    elseif params.type == awardType.TYPE_SOUL then
        local attr1 = params.entity:getAttr1()
        if params.entity.soulType == 5 or params.entity.soulType == 6 or params.entity.soulType == 7 or params.entity.soulType == 8 or params.entity.soulType == 4 then
            attr1.num = attr1.num / 10 .. "%"
        end
        tip = qy.tank.view.tip.GeneralTip.new({
            ["icon"] = qy.tank.view.BaseItem.new({
                ["fatherImg"] = params.bg,
                ["childImg"] = params.icon,
                ["offset"] = cc.p(56.5,56.5)
            }),
            -- ["color"] = params.bg,
            ["name"] = params.entity.name .. " Lv." .. params.entity.level,
            ["intro"] = attr1.name .. "+" .. attr1.num,
            ["nameTextColor"] = params.nameTextColor,
        })
    elseif params.type == awardType.PASSENGER or params.type == awardType.PASSENGER_FRAGMENT then
        --乘员 乘员碎片
        local entity = params.entity
        tip = qy.tank.view.tip.PassengerTip.new(entity, params.type)
    else
        --一般tip
        tip = qy.tank.view.tip.GeneralTip.new({
            ["icon"] = qy.tank.view.BaseItem.new({
                ["fatherImg"] = params.bg,
                ["childImg"] = params.icon,
                ["offset"] = cc.p(56.5,56.5)
            }),
            -- ["color"] = params.bg,
            ["name"] = params.name,
            ["intro"] = params.intro,
            ["nameTextColor"] = params.nameTextColor,
        })

    end
           
    return tip
end

return TipUtil