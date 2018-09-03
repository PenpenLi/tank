local SpecialSkillModel = qy.class("SpecialSkillModel", qy.tank.model.BaseModel)


function SpecialSkillModel:getSpecialSkillData(skillId)
    if skillId == "160" then
        return require("entity.skills.Skill160")
    elseif skillId == "161" then
        return require("entity.skills.Skill161")
    end

    return nil
end



return SpecialSkillModel