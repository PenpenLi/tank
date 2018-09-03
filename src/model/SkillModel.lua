local SkillModel = qy.class("SkillModel", qy.tank.model.BaseModel)


function SkillModel:init(skill)
	self.skillOBject = {}
	self.skillArray = {}
	
	for k, v in pairs(skill) do
		self.skillOBject[k] = require("entity.SkillEntity").new(v)
	end

	for k, v in pairs(skill) do
		table.insert(self.skillArray,require("entity.SkillEntity").new(v))
	end

end

function SkillModel:updateSkillById(skill)
	for k, v in pairs(skill) do
		if self.skillOBject[k] then
			self.skillOBject[k]:update(v)
		else
			self:addSkill(k, v)
		end		
	end
end

function SkillModel:addEquip(unique_id, data)
	self.skillOBject[tostring(unique_id)] = require("entity.SkillEntity").new(data)
end

--通过类型获取所有的技能
function SkillModel:getSkillDataByType(type,profession)
	local skillArray = {};
	for k, v in pairs(self.skillOBject) do
   		if(self.skillOBject[k].type == type and self:isFuheProfession(self.skillOBject[k].profession_range,profession)) then
   			table.insert(skillArray,self.skillOBject[k])
   		end
	end
	return skillArray;
end

function SkillModel:isFuheProfession(profession_range,profession)
	local isFuhe = false
	if not profession then
		isFuhe = true
	else
		for i= 1, #profession_range do
   			if profession_range[i] == profession then
   				isFuhe = true
   			end	
		end
	end
	return isFuhe
end


function SkillModel:getSkillById(id)
	return self.skillOBject[id]
end

function SkillModel:getIsHaveSkill(skillId)
	local flag = false
	for k, v in pairs(self.skillOBject) do
   		if(self.skillOBject[k].skill_id == skillId) then
   			flag = true
   			break
   		end
	end
	return flag
end

function SkillModel:getZhieyeNameByIndex(type)
	local text = ""
	if type == 1 then
		text = qy.TextUtil:substitute('defender')
	end
	if type == 2 then
		text = qy.TextUtil:substitute('enlistee')
	end
	if type == 3 then
		text = qy.TextUtil:substitute('explorer')
	end
	if type == 4 then
		text = qy.TextUtil:substitute('therapist')
	end
	if type == 5 then
		text = qy.TextUtil:substitute('adventurer')
	end
	return text
end



return SkillModel