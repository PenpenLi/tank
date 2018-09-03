--[[
    战斗请求服务
]]

local SkillService = qy.class("SkillService", qy.tank.service.BaseService)
--入口
function SkillService:skill(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "hero.changeSkill",
        ["p"] = data
    }))
    :send(function(response, request)
        
        callback()
    end)
end

function SkillService:level(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "skill.upgrade",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        local skillInfo = response.data.skill
        for k, v in pairs(skillInfo) do
        	local skillId = skillInfo[k].unique_id
        	local skillData = qy.SkillModel:getSkillById(tostring(skillId))
        	callback(skillData)
    	end
    end)
end

function SkillService:levelBeidongSkill(data,callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "skill.upgrade",
        ["p"] = data
    }))
    :send(function(response, request)
        qy.hint:show(qy.TextUtil:substitute("update_successful"))
        local heroInfo = response.data.hero
        for k, v in pairs(heroInfo) do
        	local heroId = heroInfo[k].unique_id
        	local heroData = qy.BodyModel:getHeroById(heroId)
	        local skillId = heroData.zhuskill['1'].skill_id
	        local skillData = clone(qy.Config.skill[tostring(skillId)])
        	callback(skillData)
    	end
    end)
end

return SkillService
