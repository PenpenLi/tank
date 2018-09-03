local MonsterEntity = qy.class("MonsterEntity", qy.tank.entity.BaseBodyEntity)

function MonsterEntity:ctor(data)

    self:setproperty("id",              data.id)
    self:setproperty("camp",            "monster")
    self:setproperty("direction",       "right")
    self:setproperty("configId",        data.configId)
    self:setproperty("level",           data.level or 1)
    self:setproperty("atkPosition",     data.atkPosition)
    self:setproperty("drop",            data.drop)
    self:setproperty("buffs", {})

    -- self:setproperty("cd",     data.cd)
    self:setproperty("cd",              {})

    
    local configData = qy.Config.monster[data.configId]

    self:setproperty("name",            qy.TextUtil:substitute(configData.name))
    self:setproperty("path",            "dragonBone/monster/monster"..configData.cartoon)
    self:setproperty("animationName",   "monster"..configData.cartoon)
    self:setproperty("profession",      configData.profession)
    self:setproperty("species",         configData.species)
    self:setproperty("quality",         configData.quality)
    self:setproperty("cartoon",         configData.cartoon)
    self:setproperty("headIcon",        configData.head_icon)
    self:setproperty("monsterType",     configData.type)
    self:setproperty("body",            configData.body or 1)
    self:setproperty("levelAttributes", {})
    self:setproperty("equipAttributes", {})


    local propertyData = qy.Config.property
    for k, v in pairs(propertyData) do
        local basic1 = k.."01"
        local percent1 = k.."02"
        local basic2 = k.."03"
        local percent2 = k.."04"

        self:setproperty(basic1,                configData["property_"..basic1] or 0)      
        self:setproperty(percent1,              configData["property_"..percent1] or 0)      
        self:setproperty(basic2,                configData["property_"..basic2] or 0)      
        self:setproperty(percent2,              configData["property_"..percent2] or 0)      
        self:setproperty(basic1.."_growup",     configData["property_growup_"..basic1] or 0)
        self:setproperty(percent1.."_growup",   configData["property_growup_"..percent1] or 0)
        self:setproperty(basic2.."_growup",     configData["property_growup_"..basic2] or 0)
        self:setproperty(percent2.."_growup",   configData["property_growup_"..percent2] or 0)
    end

    self:set("13401", self:getTotalProperty("106"))

    local skillsData = {}
    skillsData["1"] = {["skill_id"] = configData["skill_atk"]}
    for i = 1, 4 do
        if configData["skill_id"..i] ~= "" then
            skillsData[tostring(i + 1)] = {["skill_id"] = configData["skill_id"..i]}
        end
    end

    self:setproperty("skillsData",      skillsData)


    local longguData = qy.Config.longgu[self:get("animationName")]    

    self:setproperty("head_be_attacked",    cc.p(qy.DungeonUtil.splitByStr(longguData.head_be_attacked, "|")[1],     qy.DungeonUtil.splitByStr(longguData.head_be_attacked, "|")[2]))
    self:setproperty("head",                cc.p(qy.DungeonUtil.splitByStr(longguData.head, "|")[1],                 qy.DungeonUtil.splitByStr(longguData.head, "|")[2]))
    self:setproperty("chest_be_attacked",   cc.p(qy.DungeonUtil.splitByStr(longguData.chest_be_attacked, "|")[1],    qy.DungeonUtil.splitByStr(longguData.chest_be_attacked, "|")[2]))
    self:setproperty("chest",               cc.p(qy.DungeonUtil.splitByStr(longguData.chest, "|")[1],                qy.DungeonUtil.splitByStr(longguData.chest, "|")[2]))
    self:setproperty("foot_be_attacked",    cc.p(qy.DungeonUtil.splitByStr(longguData.foot_be_attacked, "|")[1],     qy.DungeonUtil.splitByStr(longguData.foot_be_attacked, "|")[2]))
    self:setproperty("foot",                cc.p(qy.DungeonUtil.splitByStr(longguData.foot, "|")[1],                 qy.DungeonUtil.splitByStr(longguData.foot, "|")[2]))

end


return MonsterEntity