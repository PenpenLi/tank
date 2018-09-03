local EquipEntity = qy.class("EquipEntity", qy.tank.entity.BaseEntity)

function EquipEntity:ctor(data)    
    self:setproperty("uniqueid",              data.unique_id)
     --配置id
    self:setproperty("configId",        tostring(data.equip_id))
    --英雄穿戴id
    self:setproperty("heroOnId",        data.hero_unique_id)
    --装备位置
    self:setproperty("pos",              data.pos)
    --资源类型 3是装备
    self:setproperty("resouce_type",              3)
    self:setproperty("strengthen_level",              data.strengthen_level)
    self:setproperty("equip_skill",              data.equip_skill)
    self:setproperty("prime",              data.prime)
    self:setproperty("minor",              data.minor)
    self:setproperty("is_lock",              data.is_lock)
    print(data.equip_id)
    local propertyData = qy.Config.equipment[tostring(data.equip_id)]
    for k, v in pairs(propertyData) do
        self:setproperty(k, v)
    end      
end

function EquipEntity:update(data)
    self:set("pos",           data.pos)
    self:set("heroOnId",          data.hero_unique_id)
    self:set("strengthen_level",          data.strengthen_level)
    self:set("prime",          data.prime)
    self:set("equip_skill",          data.equip_skill)
    self:set("minor",          data.minor)
    self:set("is_lock",          data.is_lock)
end


return EquipEntity