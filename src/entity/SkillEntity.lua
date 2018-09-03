local SkillEntity = qy.class("SkillEntity", qy.tank.entity.BaseEntity)

function SkillEntity:ctor(data)    
    --唯一id
    self:setproperty("uniqueid",data.unique_id)
    self:setproperty("hero_unique_id",data.hero_unique_id)
    --self:setproperty("path","dragonBone/hero/role"..configData.cartoon)
    local propertyData = qy.Config.skill[tostring(data.skill_id)]
    for k, v in pairs(propertyData) do
        self:setproperty(k, v)
    end

end

function SkillEntity:update(data)
    self:set("uniqueid",           data.unique_id)
    self:set("hero_unique_id",          data.hero_unique_id)
    local propertyData = qy.Config.skill[tostring(data.skill_id)]
    for k, v in pairs(propertyData) do
        self:set(k,v)
    end
end


return SkillEntity