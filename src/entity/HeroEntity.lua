local HeroEntity = qy.class("HeroEntity", qy.tank.entity.BaseBodyEntity)

function HeroEntity:ctor(data)    
    --唯一id
    self:setproperty("id",              data.unique_id)
    --阵容
    self:setproperty("camp",            "hero")
    --方向
    self:setproperty("direction",       "left")
    --配置id
    self:setproperty("configId",        tostring(data.hero_id))        
    --名称
    self:setproperty("name",            data.name)    
    --等级
    self:setproperty("level",           data.level or 1)
    --是否死亡
    self:setproperty("is_die",          data.is_die)
    --装备
    self:setproperty("equip",           data.equip)
    --压力值
    self:setproperty("11301",           data.pressure or 0)
    --技能
    self:setproperty("zhuskill",        data.skill)
    --扎营技能
    self:setproperty("camp_skill",      data.camp_skill)
    --0-空闲，1-上阵
    self:setproperty("status",          data.status)
    --体力
    self:setproperty("vitality",        data.vitality)
    --怪癖
    self:setproperty("quirks",          data.quirks)
    --被锁住的怪癖
    self:setproperty("quirks_lock",     data.quirks_lock)
    --饱腹值
    self:setproperty("satiety",         data.satiety)
    --经验值
    self:setproperty("exp",             data.exp)    
    --阵位
    self:setproperty("atkPosition",     data.atkPosition or data.position)
    --崩溃觉醒相关 special = {["done"] = 1, ["type"] = 1 1崩溃2觉醒}
    self:setproperty("special",         data.special)

    -- self:setproperty("buffs",           {})
    self:setproperty("buffs",           data.buff)
    -- self:setproperty("buffs",           {})
    self:setproperty("quirks",          data.quirks)

    -- self:setproperty("cd",     data.cd)
    self:setproperty("cd",              {})
    self:setproperty("treat",          data.treat)

    local configData = qy.Config.hero[self:get("configId")]

    self:setproperty("path",            "dragonBone/hero/role"..configData.cartoon)
    self:setproperty("animationName",   "role"..configData.cartoon)    
    self:setproperty("profession",      configData.profession)
    self:setproperty("species",         configData.species)
    self:setproperty("quality",         configData.quality)
    self:setproperty("cartoon",         configData.cartoon)
    self:setproperty("headIcon",        configData.head_icon)
    self:setproperty("body",            configData.body or 1)
    self:setproperty("levelAttributes", {})
    self:setproperty("equipAttributes", {})

    local propertyData = qy.Config.property
    for k, v in pairs(propertyData) do
        local basic1 = k.."01"
        local percent1 = k.."02"
        local basic2 = k.."03"
        local percent2 = k.."04"

        self:setproperty(basic1,    configData["property_"..basic1] or 0)      
        self:setproperty(percent1,  configData["property_"..percent1] or 0)      
        self:setproperty(basic2,    configData["property_"..basic2] or 0)      
        self:setproperty(percent2,  configData["property_"..percent2] or 0)
        self:setproperty(basic1.."_growup",     configData["property_growup_"..basic1] or 0)
        self:setproperty(percent1.."_growup",   configData["property_growup_"..percent1] or 0)
        self:setproperty(basic2.."_growup",     configData["property_growup_"..basic2] or 0)
        self:setproperty(percent2.."_growup",   configData["property_growup_"..percent2] or 0)
    end


    local skillsData = {}
    skillsData["1"] = {["skill_id"] = configData["skill_atk"]}
    for i = 1, 4 do
        if data["skill"][tostring(i)] == -1 then
            skillsData[tostring(i + 1)] = -1
        elseif not data["skill"][tostring(i)]["skill_id"] then
            skillsData[tostring(i + 1)] = -2
        else
            skillsData[tostring(i + 1)] = {["skill_id"] = tostring(data["skill"][tostring(i)]["skill_id"]), ["upgrade_id"] = tostring(data["skill"][tostring(i)]["upgrade_id"]), ["unique_skill_id"] = tostring(data["skill"][tostring(i)]["unique_skill_id"])}
        end
    end
    
    self:setproperty("skillsData",      skillsData)


    
    self:set("13401", math.min(self:getTotalProperty("106"), data.blood))
    self:set("13501", 5 + self:getTotalProperty("225"))
    

    local longguData = qy.Config.longgu[self:get("animationName")]

    self:setproperty("head_be_attacked",    cc.p(qy.DungeonUtil.splitByStr(longguData.head_be_attacked, "|")[1],     qy.DungeonUtil.splitByStr(longguData.head_be_attacked, "|")[2]))
    self:setproperty("head",                cc.p(qy.DungeonUtil.splitByStr(longguData.head, "|")[1],                 qy.DungeonUtil.splitByStr(longguData.head, "|")[2]))
    self:setproperty("chest_be_attacked",   cc.p(qy.DungeonUtil.splitByStr(longguData.chest_be_attacked, "|")[1],    qy.DungeonUtil.splitByStr(longguData.chest_be_attacked, "|")[2]))
    self:setproperty("chest",               cc.p(qy.DungeonUtil.splitByStr(longguData.chest, "|")[1],                qy.DungeonUtil.splitByStr(longguData.chest, "|")[2]))
    self:setproperty("foot_be_attacked",    cc.p(qy.DungeonUtil.splitByStr(longguData.foot_be_attacked, "|")[1],     qy.DungeonUtil.splitByStr(longguData.foot_be_attacked, "|")[2]))
    self:setproperty("foot",                cc.p(qy.DungeonUtil.splitByStr(longguData.foot, "|")[1],                 qy.DungeonUtil.splitByStr(longguData.foot, "|")[2]))
end


function HeroEntity:update(data)
    --等级
    if data.level ~= self:get("level") then
        self:set("level",           data.level or 1)
        self:set("levelAttributes", {})
    end
    --是否死亡
    self:set("is_die",          data.is_die)
    --装备
    self:set("equip",           data.equip)    
    self:set("equipAttributes", {})
    --压力值
    self:set("11301",           data.pressure or 0)
    --0-空闲，1-上阵
    self:set("status",          data.status)
    --体力
    self:set("vitality",        data.vitality)
    --饱腹值
    self:set("satiety",         data.satiety)
    --经验值
    self:set("exp",             data.exp)    
    --阵位
    self:set("atkPosition",     data.atkPosition or data.position)

    self:set("buffs",           data.buff)
    --怪癖
    self:set("quirks",          data.quirks)

    self:set("zhuskill",        data.skill)
    self:set("quirks_lock",        data.quirks_lock)
    self:set("treat",        data.treat)
    --skill
    --camp_skill

    self:set("13401", math.min(self:getTotalProperty("106"), data.blood))
end





return HeroEntity