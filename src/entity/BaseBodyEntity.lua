local BaseBodyEntity = qy.class("BaseBodyEntity", qy.tank.entity.BaseEntity)

function BaseBodyEntity:set(name, value)    
    BaseBodyEntity.super.set(self, name, value)
end


function BaseBodyEntity:get(name)
    if name == "campAtkPosition" then
        return self:get("camp")..self:get("atkPosition")
    end

    return BaseBodyEntity.super.get(self, name)
end


--获取后端可以用的数据
function BaseBodyEntity:getServiceUseData()
    local result = {}
    result["unique_id"] = self:get("id")
    result["blood"] = self:getTotalProperty("134")
    result["pressure"] = self:getTotalProperty("113")
    result["is_die"] = self:isDie() and 1 or 0
    result["special"] = self:get("special")

    return result
end

-- function BaseBodyEntity:initProperty()
--     for i = 1, #qy.DungeonConfig.bodyPropertyKeys do
--         --基础属性
--         self:setproperty("BASIC_"..qy.DungeonConfig.bodyPropertyKeys[i], 0)
--     end

--     for i = 1, #qy.DungeonConfig.bodyPropertylevelKeys do
--         --力量,敏捷,体质,魔力
--         self:setproperty(qy.DungeonConfig.bodyPropertylevelKeys[i], 0)
--     end
-- end


-- function BaseBodyEntity:setBasicProperty(_type, num)
--     self:initProperty()

--     if _type and num and string.find(_type, "_") then
--     	local types = qy.tank.utils.String.split(_type, "_")
--     	local nums  = qy.tank.utils.String.split(num, "_")

--     	for i = 1, #types do
--     		self:set(qy.Config.property_type[types[i]].type, tonumber(nums[i]))
--     	end
--     end

--     self:setproperty("HP", self:get("BASIC_MAX_HP"))
-- end



function BaseBodyEntity:updateHP(updateHP)
    if updateHP and type(updateHP) == "number" then
        local hp = self:getTotalProperty("134")
        -- hp = math.max(math.min(hp + updateHP, self:getTotalProperty("MAX_HP")), 0)
        hp = math.max(math.min(hp + updateHP, self:getTotalProperty("106")), 0)
        self:set("13401", hp)

        if hp <= 0 then
            self.just_dead = true
        end

        return hp
    end
end


--获得总属性
function BaseBodyEntity:getTotalProperty(key)

    local fun = function(key)
        --只有当前血量不跟任何有关系
        local buffAttribute = self:getBuffAttribute()
        local equipAttribute = self:getEquipAttribute()
        local levelAttribute = self:getLevelAttribute()
        local result = 0

        if string.len(key) == 3 then
            local basic1 = 0
            local basic2 = 0
            local plus1 = 0
            local plus2 = 0
            local plusPercent1 = 1000
            local plusPercent2 = 1000

            --基础属性
            basic1 = self:get(key.."01") or 0
            basic2 = self:get(key.."03") or 0

            --buff加成
            plus1 = plus1 + (buffAttribute[key.."01"] or 0)
            plus2 = plus2 + (buffAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (buffAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (buffAttribute[key.."04"] or 0)

            --装备加成
            plus1 = plus1 + (equipAttribute[key.."01"] or 0)
            plus2 = plus2 + (equipAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (equipAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (equipAttribute[key.."04"] or 0)

            --等级加成
            plus1 = plus1 + (levelAttribute[key.."01"] or 0)
            plus2 = plus2 + (levelAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (levelAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (levelAttribute[key.."04"] or 0)

            result = (basic1 + plus1) * plusPercent1 / 1000

            local coefficientConfig = qy.Config.fight_coefficient
            --当一个属性在系数表里存在系数时，就代表它是一个需要公式计算最终结果的属性
            if key =="107"then
               -- print(result , basic2, plus2, plusPercent2, self:get("level") , coefficientConfig["level"]["coeffcient"] , coefficientConfig[key]["coeffcient"])
            end
            if coefficientConfig[key] and type(coefficientConfig[key]["coeffcient"]) == "number" then
                --按公式算出来的是百分比 但咱们都是按千分比的 所以公式最后再乘以十
                result = result / (self:get("level") + coefficientConfig["level"]["coeffcient"]) / coefficientConfig[key]["coeffcient"]
            end
            result = (result + basic2 + plus2) * plusPercent2 / 1000

        elseif string.len(key) == 5 then

            result = self:get(key) + (buffAttribute[key] or 0) + (equipAttribute[key] or 0) + (levelAttribute[key] or 0)
        end

        --一些值有上限的属性。压力200， 能量10
        if string.sub(key, 1, 3) == "113" then
            -- result = math.abs(math.min(200, result), 0)
        elseif string.sub(key, 1, 3) == "135" then            
            result = math.abs(math.min(10, result), 0)
        end

        if string.sub(key, 1, 3) == "103" then
            result = equipAttribute["10301"] or self:get("10301")
        elseif string.sub(key, 1, 3) == "104" then
            result = equipAttribute["10401"] or self:get("10401")
        end
        
        return math.floor(result)
    end

    local result = {}
    if key and type(key) == "string" then
        return fun(key)
    else
        for k, v in pairs(qy.Config.property) do
            result[k] = fun(k)
            result[k.."01"] = fun(k.."01")
            result[k.."02"] = fun(k.."02")
        end
    end

    -- print(qy.json.encode(result))

    return result
end



--------------------------------------------------------------------------------------------------------------------------------装备 start
--获取装备属性加成
function BaseBodyEntity:getEquipAttribute()
    local equipAttributes = self:get("equipAttributes") or {}

    function addProperty(data)
        local id = data["propertyId"]
        local value = data["effectValue"]

        if not equipAttributes[tostring(id)] then    
            equipAttributes[tostring(id)] = 0
        end
        equipAttributes[tostring(id)] = equipAttributes[tostring(id)] + value
    end

    if qy.DungeonUtil.getTableLength(equipAttributes) == 0 then
        local equip = self:get("equip")
        if equip then
            for i = 1, 6 do
                local prime = equip[tostring(i)]["prime"]
                local minor = equip[tostring(i)]["minor"]
                local equip_skill = equip[tostring(i)]["equip_skill"]
              
                local array = {prime, minor, equip_skill}

                for j = 1, #array do
                    for k = 1, #array[j] do
                        addProperty(array[j][k])
                    end
                end
            end
        end
        self:set("equipAttributes", equipAttributes)
    end

    return equipAttributes
end

--------------------------------------------------------------------------------------------------------------------------------装备 end



--------------------------------------------------------------------------------------------------------------------------------等级 start
--获取等级属性加成
function BaseBodyEntity:getLevelAttribute()
    local levelAttributes = self:get("levelAttributes")

    if qy.DungeonUtil.getTableLength(levelAttributes) == 0 then
        for k, v in pairs(qy.Config.property) do        
            levelAttributes[k.."01"] = (self:get(k.."01_growup") or 0) * (self:get("level") - 1)
            levelAttributes[k.."02"] = (self:get(k.."02_growup") or 0) * (self:get("level") - 1)
            levelAttributes[k.."03"] = (self:get(k.."03_growup") or 0) * (self:get("level") - 1)
            levelAttributes[k.."04"] = (self:get(k.."04_growup") or 0) * (self:get("level") - 1)
        end
        self:set("levelAttributes", levelAttributes)
    end
    
    return levelAttributes
end

--------------------------------------------------------------------------------------------------------------------------------等级 end




--------------------------------------------------------------------------------------------------------------------------------buff start

--通过buff更新状态，基本就是中毒，流血这些掉血的
--返回数据类型用于显示  格式为{["campAtkPosition"] = "", ["effectValue"] = "", ["property"] = ""}
function BaseBodyEntity:iterationBuff()
    ----分成两段更新，第一段只迭代血量相关的，下面的先判断死没死，没死再迭代其他的
    local result = {}
    local buffs = self:get("buffs")
    for id, buffData in pairs(buffs) do
        for idx = 1, 3 do
            if buffData[tostring(idx)] then
                local effectValue = buffData[tostring(idx)]["effectValue"]
                local property = buffData[tostring(idx)]["property"] 
                local info = {["campAtkPosition"] = self:get("campAtkPosition"), ["effectValue"] = effectValue, ["property"] = "134", ["showName"] = false}

                --流血, 固定值
                if property == "20401" then
                    table.insert(result, info)
                    qy.BattleBodyModel:updateBodyHp(self, effectValue)
                --中毒
                elseif property == "20501" then
                    table.insert(result, info)
                    qy.BattleBodyModel:updateBodyHp(self, effectValue)
                end
            end
        end
    end

    if not self:isDie() then
        for id, buffData in pairs(buffs) do
            for idx = 1, 3 do
                if buffData[tostring(idx)] then
                    local effectValue = buffData[tostring(idx)]["effectValue"]
                    local property = buffData[tostring(idx)]["property"] 
                    local info = {["campAtkPosition"] = self:get("campAtkPosition"), ["effectValue"] = effectValue, ["showName"] = false}

                    --行动前回血
                    if property == "11701" then
                        info["property"] = "134"
                        table.insert(result, info)
                        qy.BattleBodyModel:updateBodyHp(self, effectValue)
                    --暗影变身
                    elseif property == "21701" then
                        --刚上来等于-2
                        if effectValue == -2 then                        
                            buffData[tostring(idx)]["effectValue"] = -1
                        elseif effectValue == 1 then
                            buffData[tostring(idx)]["effectValue"] = -1
                        elseif effectValue == -1 then
                            info["property"] = 217
                            table.insert(result, info)

                            buffData[tostring(idx)]["effectValue"] = 1
                            self:addBuff(
                                {["id"]         = "124001", 
                                ["idx"]         = "2", 
                                ["skillType"]   = "2"})
                            self:addBuff(
                                {["id"]         = "124001", 
                                ["idx"]         = "3",  
                                ["skillType"]   = "2"})
                        end
                    end
                end
            end
        end
    end

    return result
end


--更新buffCD
function BaseBodyEntity:iterationBuffCD()
    local buffs = self:get("buffs")
    for id, buffData in pairs(buffs) do
        for idx = 1, 3 do
            if buffData[tostring(idx)] and buffData[tostring(idx)]["duration"] > 0 then
                buffData[tostring(idx)]["duration"] = buffData[tostring(idx)]["duration"] - 1

                if buffData[tostring(idx)]["duration"] == 0 then
                    buffData[tostring(idx)] = nil
                end

                buffs[id] = buffData
            end
        end

        if qy.DungeonUtil.getTableLength(buffs[id]) == 0 then
            buffs[id] = nil
        end
    end

    self:set("buffs", buffs)
end


--添加buff
--返回数据类型用于显示  格式为{["campAtkPosition"] = "", ["effectValue"] = "", ["property"] = ""}
function BaseBodyEntity:addBuff(buffData, show)
    local buff          = qy.Config.buff[tostring(buffData["id"])] or {}
    local idx           = buffData["idx"] or 0
    --附加属性
    buffData["property"]     = buffData["property"]     or buff["property_"..idx]
    --效果值
    buffData["effectValue"]  = buffData["effectValue"]  or buff["effect_value"..idx]
    --持续回合数
    buffData["duration"]     = buffData["duration"]     or buff["duration"..idx]
    --叠加规则
    buffData["overlyRule"]   = buffData["overlyRule"]   or buff["overly_rule"..idx]

    if not buffData["property"] or buffData["property"] == "" or
        not buffData["effectValue"] or buffData["effectValue"] == "" then

        return
    end

    --在这里要计算所有包括buff的叠加问题，添加流血中毒类buff时计算抗性的问题
    local buffs = self:get("buffs")

    --叠加规则 
    local overlyRule = buffData["overlyRule"]

    --是否已经生效了，或者说覆盖了旧buff
    local flag1 = false
    --是否存在相同类型的buff
    local flag2 = false

    local showResult = {["campAtkPosition"] = self:get("campAtkPosition"), ["effectValue"] = buffData["effectValue"], ["property"] = buffData["property"]}

    --如果添加的是眩晕附加抵抗buff
    if buffData["property"] == "20301" then --眩晕
        self:addBuff(
            {["id"]         = "997", 
            ["idx"]         = "1",  
            ["skillType"]   = "1"})
    end

    --生命当前值
    if buffData["property"] == "13401" then
        self:updateHP(buffData["effectValue"])
        flag1 = true
        showResult["showName"] = false
    --生命最大值百分比
    elseif buffData["property"] == "22301" then
        self:updateHP(self:getTotalProperty("106") * buffData["effectValue"] / 1000)
        flag1 = true
        showResult["showName"] = false

    --压力值与能量则直接加在人物身上，不做为buff临时效果
    elseif buffData["property"] == "11301" then
        if self:get("11301") < 200 or buffData["effectValue"] < 0 then
            self:set("11301", math.min(buffData["effectValue"] + self:get("11301"), 200))
        elseif self:get("11301") >= 200 and buffData["effectValue"] > 0 and qy.DungeonUtil.random(100) < 30 then 
            self.just_dead = true
            self:set("11301", buffData["effectValue"] + self:get("11301"))
        end
        flag1 = true
        showResult["showName"] = false

        if buffData["effectValue"] > 0 
            and qy.UserInfoModel:getUserDataByKey("level") < 5 
            and cc.UserDefault:getInstance():getStringForKey("yali_yindao", "0") == "0" then

            cc.UserDefault:getInstance():setStringForKey("yali_yindao", "1")
            qy.Event.dispatch(qy.Event.YA_LI_ZHI_YIN_DAO)
        end
    elseif buffData["property"] == "13501" then
        self:set(buffData["property"], math.min(buffData["effectValue"] + self:get(buffData["property"]), 10))
        flag1 = true
        showResult["showName"] = false
    --215移除负面效果，216移除正面效果
    elseif buffData["property"] == "21501" or buffData["property"] == "21601" then
        local result = {}
        for k, v in pairs(buffs) do
            local buffConfigData = qy.Config.buff[k]
            if  buffConfigData["skillType"] ~= 3 and
                (buffConfigData["Positive_negative"] == 1 and buffData["property"] == "21601") or
                (buffConfigData["Positive_negative"] == 2 and buffData["property"] == "21501") then

                table.insert(result, k)
            end
        end

        if #result > 0 then
            buffs[result[qy.DungeonUtil.random(#result)]] = nil
        end
        flag1 = true
        show = false
--------------------------------------判断叠加规则开始
--1相同技能类型下，取高值。
--2无限叠加，数值叠加，回合取最高。
--3永不叠加，取高值，区别类型1，不考虑技能类型
-------正面buff与负面buff之间不考虑叠加关系
    elseif overlyRule == 1 then
        --寻找同技能类型，属性类型相同
        for k, v in pairs(buffs) do
            for i = 1, 3 do
                local data = v[tostring(i)]
                if data then
                    if data["overlyRule"] == buffData["overlyRule"] and data["skillType"] == buffData["skillType"] and data["Positive_negative"] == buffData["Positive_negative"] then
                        if data["property"] == buffData["property"] then
                            flag2 = true
                            --效果相同，取时间长
                            if data["effectValue"] == buffData["effectValue"] and data["duration"] < buffData["duration"] then
                                buffs[k][tostring(i)]["duration"] = buffData["duration"]
                                flag1 = true
                                break
                            --效果不同取效果强
                            elseif data["effectValue"] < buffData["effectValue"] then
                                buffs[k][tostring(i)] = buffData
                                flag1 = true
                                break
                            end
                        end
                    end
                end

                if flag1 then break end
            end
        end
    elseif overlyRule == 2 then
        for k, v in pairs(buffs) do
            for i = 1, 3 do
                local data = v[tostring(i)]
                if data and data["overlyRule"] == buffData["overlyRule"] and data["Positive_negative"] == buffData["Positive_negative"] then
                    if data["property"] == buffData["property"] then
                        buffs[k][tostring(i)]["duration"] = math.max(data["duration"], buffData["duration"])
                        buffs[k][tostring(i)]["effectValue"] = buffs[k][tostring(i)]["effectValue"] + buffData["effectValue"]
                        flag1 = true
                        break
                    end
                end
            end

            if flag1 then break end
        end
    end
--------------------------------------判断叠加规则结束

    --没有覆盖，没有同类型属性时，才新增
    if not flag1 and not flag2 then
        if buffs[tostring(buffData["id"])] == nil then
            buffs[tostring(buffData["id"])] = {}
        end
        buffs[tostring(buffData["id"])][buffData["idx"]] = buffData

        flag1 = true
    end

    --只有生效了，并且show不等于false时 显示
    if flag1 == true and show ~= false then
        qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, showResult)   
    end

    self:set("buffs", buffs)

    return buffData
end


--获取总buff属性加成
function BaseBodyEntity:getBuffAttribute()
    local buffs = self:get("buffs")
    local quirks = self:get("quirks") or {}
    local attributes = {}
    for id, buff in pairs(buffs) do
        for idx = 1, 3 do
            if tostring(id) == "300701" then
                print("property", buff[tostring(1)]["property"])
            end
            local data = buff[tostring(idx)]
            if data and data["duration"] ~= 0 then
                local attrType = tostring(data["property"])
                local attrNum = data["effectValue"]
                attributes[attrType] = (attributes[attrType] or 0) + (attrNum or 0)
            end
        end
    end

    for id, buff in pairs(quirks) do
        for idx = 1, 3 do
            local data = buff[tostring(idx)]
            if data and data["duration"] ~= 0 then
                local attrType = tostring(data["property"])
                local attrNum = data["effectValue"]
                attributes[attrType] = (attributes[attrType] or 0) + (attrNum or 0)
            end
        end
    end


    return attributes
end
--------------------------------------------------------------------------------------------------------------------------------buff end





--更新能量
function BaseBodyEntity:addEnergy(num)
    self:set("13501", math.max(math.min(self:get("13501") + num, 10), 0))
end

--添加cd
function BaseBodyEntity:addCD(key, time)    
    local cd = self:get("cd")
    cd[key] = time
    self:set("cd", cd)
end

--获得一个cd
function BaseBodyEntity:getCDByKey(key)
    return self:get("cd")[key]
end

--迭代cd，buffcd
function BaseBodyEntity:iterationCD()
    local cd = self:get("cd")
    for k, v in pairs(cd) do
        if type(v) == "number" and v > 0 then
            cd[k] = cd[k] - 1

            if cd[k] == 0 then
                cd[k] = nil
            end
        else
            cd[k] = nil
        end
    end
    self:set("cd", cd)

    self:iterationBuffCD()
end


function BaseBodyEntity:isDie()
    return self:getTotalProperty("134") <= 0 or (self:getTotalProperty("11301") > 200 and self:get("special")["type"] == 2)
end

--获得总属性
function BaseBodyEntity:getTotalProperty1(key,equipData,equipId,curIndex)

    local fun = function(key)
        --只有当前血量不跟任何有关系
        local buffAttribute = self:getBuffAttribute()
        local equipAttribute = self:getEquipAttribute1(equipData,equipId,curIndex)
        local levelAttribute = self:getLevelAttribute()
        local result = 0

        if string.len(key) == 3 then
            local basic1 = 0
            local basic2 = 0
            local plus1 = 0
            local plus2 = 0
            local plusPercent1 = 1000
            local plusPercent2 = 1000

            --基础属性
            basic1 = self:get(key.."01") or 0
            basic2 = self:get(key.."03") or 0

            --buff加成
            plus1 = plus1 + (buffAttribute[key.."01"] or 0)
            plus2 = plus2 + (buffAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (buffAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (buffAttribute[key.."04"] or 0)

            --装备加成
            plus1 = plus1 + (equipAttribute[key.."01"] or 0)
            plus2 = plus2 + (equipAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (equipAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (equipAttribute[key.."04"] or 0)

            --等级加成
            plus1 = plus1 + (levelAttribute[key.."01"] or 0)
            plus2 = plus2 + (levelAttribute[key.."03"] or 0)
            plusPercent1 = plusPercent1 + (levelAttribute[key.."02"] or 0)
            plusPercent2 = plusPercent2 + (levelAttribute[key.."04"] or 0)

            result = (basic1 + plus1) * plusPercent1 / 1000

            local coefficientConfig = qy.Config.fight_coefficient
            --当一个属性在系数表里存在系数时，就代表它是一个需要公式计算最终结果的属性
            if key =="107"then
                --print(result , basic2, plus2, plusPercent2, self:get("level") , coefficientConfig["level"]["coeffcient"] , coefficientConfig[key]["coeffcient"])
            end
            if coefficientConfig[key] and type(coefficientConfig[key]["coeffcient"]) == "number" then
                --按公式算出来的是百分比 但咱们都是按千分比的 所以公式最后再乘以十
                result = result / (self:get("level") + coefficientConfig["level"]["coeffcient"]) / coefficientConfig[key]["coeffcient"]
            end
            result = (result + basic2 + plus2) * plusPercent2 / 1000

        elseif string.len(key) == 5 then

            result = self:get(key) + (buffAttribute[key] or 0) + (equipAttribute[key] or 0) + (levelAttribute[key] or 0)
        end

        --一些值有上限的属性。压力200， 能量10
        if string.sub(key, 1, 3) == "113" then
            -- result = math.abs(math.min(200, result), 0)
        elseif string.sub(key, 1, 3) == "135" then            
            result = math.abs(math.min(10, result), 0)
        end

        if string.sub(key, 1, 3) == "103" then
            result = equipAttribute["10301"] or self:get("10301")
        elseif string.sub(key, 1, 3) == "104" then
            result = equipAttribute["10401"] or self:get("10401")
        end
        
        return math.floor(result)
    end

    local result = {}
    if key and type(key) == "string" then
        return fun(key)
    else
        for k, v in pairs(qy.Config.property) do
            result[k] = fun(k)
            result[k.."01"] = fun(k.."01")
            result[k.."02"] = fun(k.."02")
        end
    end

    -- print(qy.json.encode(result))

    return result
end

--获取装备属性加成
function BaseBodyEntity:getEquipAttribute1(eqipData,equipId,curIndex)
    local equipAttributes = {}
    function addProperty1(data)
        local id = data["propertyId"]
        local value = data["effectValue"]
        if not equipAttributes[tostring(id)] then    
            equipAttributes[tostring(id)] = 0
        end
        equipAttributes[tostring(id)] = equipAttributes[tostring(id)] + value
    end

    if qy.DungeonUtil.getTableLength(equipAttributes) == 0 then
        local equip = self:get("equip")
        if equip then
            for i = 1, 6 do
                --print('888888888',equip[tostring(i)]["unique_equip_id"],equipId)
                local minor = nil
                if equip[tostring(i)]["unique_equip_id"] and equip[tostring(i)]["unique_equip_id"]== equipId then
                    minor =eqipData
                else
                    if i and i == curIndex then
                        minor =eqipData
                    else
                        minor = equip[tostring(i)]["minor"]
                    end
                    
                end
                local array = {minor}
               
                for i = 1, #array do
                    for j = 1, #array[i] do
                        addProperty1(array[i][j])
                    end
                end
            end
        end
    end

    return equipAttributes
end

return BaseBodyEntity
