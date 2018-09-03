local BattleBodyModel = qy.class("BattleBodyModel", qy.tank.model.BaseModel)


function BattleBodyModel:init(data)

end


-- function BattleBodyModel:setHeroData(formationData)
-- 	if formationData then
-- 		-- formationData = {		
-- 		-- 	["1"] = {["id"] = "1", ["configId"] = "1001", ["name"] = "大电炮", ["level"] = 5},
-- 		-- 	["2"] = {["id"] = "2", ["configId"] = "1002", ["name"] = "二踢脚", ["level"] = 5},
-- 		-- 	["3"] = {["id"] = "3", ["configId"] = "1003", ["name"] = "二踢脚", ["level"] = 5},
-- 		-- 	["4"] = {["id"] = "4", ["configId"] = "1004", ["name"] = "二踢脚", ["level"] = 5},
-- 		-- }


-- 		self.bodys = {}

-- 		for k, v in pairs(formationData) do
-- 			if v ~= 0 then

-- 				self:addBody(k, v, "hero")
-- 			end
-- 		end
-- 	end
-- end



function BattleBodyModel:setBattleMonsterData(monsterFormationData, monsterDropData)
	for k, v in pairs(monsterFormationData) do
		if type(v) == "table" then

			if monsterDropData then
				v["drop"] = monsterDropData[tostring(k)]
			end
		end

		self:addBody(k, v, "monster")
	end
end



--bodys下 ["hero_1"]与["1"]对应英雄1位， ["monster_1"]与["11"]对应怪物1位
function BattleBodyModel:addBody(atkPosition, data, camp)
	local campAtkPosition = camp..atkPosition
	local entity 		  = data

	if type(data) == "table" then
		data["atkPosition"] = tostring(atkPosition)

		if camp == "hero" then
			-- entity = clone(qy.BodyModel:getHeroById(data["unique_id"]))
			-- entity:set("atkPosition", data["atkPosition"])			
			entity = require("entity.HeroEntity").new(data)
		else
			data["level"] = qy.DungeonModel:getExploreData()["difficulty_level"]
			entity = require("entity.MonsterEntity").new(data)
		end
		campAtkPosition = entity:get("campAtkPosition")
	end

	if not self.bodys then
		self.bodys = {}
	end
	self.bodys[campAtkPosition] = entity
end

function BattleBodyModel:getHeroById(id)
	return self.bodys["hero"..id]
end


function BattleBodyModel:addBodyInBattle(atkPosition, data)
	self:addBody(atkPosition, data, "monster")
	qy.Event.dispatch(qy.Event.ADD_MONSTER_IN_BATTLE)
end



function BattleBodyModel:updateBattleHero(battleHero)
	if battleHero then
		for i = 1, 4 do
			if self.bodys and self.bodys["hero"..i] then

				local flag = true
				for newAtkPosition, newHeroData in pairs(battleHero) do
					if self.bodys["hero"..i]:get("id") == newHeroData["unique_id"] then
						flag = false
						self.bodys["hero"..i]:update(newHeroData)
					end
				end
				if flag then
					self.bodys["hero"..i]:set("13401", 0)
					-- self.bodys["hero"..i] = nil
				end
			elseif battleHero[tostring(i)] then
				self:addBody(i, battleHero[tostring(i)], "hero")
			end
		end

		qy.Event.dispatch(qy.Event.BODY_INFO_UPDATE)
	end
end

function BattleBodyModel:updateCampAtkPosition(pos1, pos2)

	local body = self.bodys["hero"..pos1]
	self.bodys["hero"..pos1] = self.bodys["hero"..pos2]
	self.bodys["hero"..pos2] = body

	-- if self.bodys["hero"..pos1] then
	-- 	self.bodys["hero"..pos1]:set("atkPosition", pos1)
	-- 	self.bodys["hero"..pos1]:set("campAtkPosition", "hero"..pos1)
	-- end

	-- if self.bodys["hero"..pos2] then
	-- 	self.bodys["hero"..pos2]:set("atkPosition", pos2)
	-- 	self.bodys["hero"..pos2]:set("campAtkPosition", "hero"..pos2)
	-- end

end


--更新速度队列
function BattleBodyModel:updateSpeedQueue()
	-- body
	local bodys = self:getBodys()
	local str = ""
	
	--根据阵位，与左右两边，在原速度基础上添加0.1，规则是英雄方速度集体加0.1，然后双方阵位基础上，阵位4不加，从3开始加0.01，2加0.02，1加0.03
	--根据这个规则，可以实现相同速度下，我方阵位英雄优先出手，同一方下，阵位在前的先出手
	function addSpeedByAtkPos(atkPosition)
		if atkPosition == "1" then
			return 0.03
		elseif atkPosition == "2" then
			return 0.02
		elseif atkPosition == "3" then
			return 0.01
		end
		return 0
	end

	--如果需要在队列中做变更动画，可以保留上一个speedQueue,然后对比差异，做动画
	self.speedQueue = {}
	--已经行动过的
	self.endRound = self.endRound or {} 

	for k, v in pairs(bodys) do
		if type(v) == "table" and not v:isDie() then
			v["speed"] = v:getTotalProperty("133")
			if v:get("camp") == "hero" then
				v["speed"] = v["speed"] + 1110.1
			end
			v["speed"] = v["speed"] + addSpeedByAtkPos(v:get("atkPosition")) + (self.endRound[v:get("id")] or 0)
			table.insert(self.speedQueue, v)
		end
	end

	table.sort(self.speedQueue, function(a, b)
		return a["speed"] > b["speed"]
	end)

	-- self.endRound[self.speedQueue[1]:get("id")] = (self.endRound[self.speedQueue[1]:get("id")] or 0) - 10000
	self.endRound[self.speedQueue[1]:get("id")] = self:getBodyRoundNum() * -10000 - 10000

    qy.DungeonUtil.asynExecute(function()
    	qy.Event.dispatch(qy.Event.BATTLE_UPDATE_QUEUE)
    end, 0.01)
end


function BattleBodyModel:getBodyRoundNum()
	if self.endRound then
		return math.abs(math.floor((self.endRound[self.speedQueue[1]:get("id")] or 0) / -10000))
	end
	return 1
end



function BattleBodyModel:resumeAllBodySpeed()
	self.endRound = {}
end



--获取速度队列
function BattleBodyModel:getSpeedQueue()
	if self.speedQueue == nil or #self.speedQueue == 0 then
		self:updateSpeedQueue()
	end

	return self.speedQueue
end



--获取当前应该出手的对象
function BattleBodyModel:getNextBody()
	return self:getSpeedQueue()[1]
end


--获取另一个阵营的bodys
function BattleBodyModel:getOtherBodysByCamp(camp)
	if camp == "hero" then
		return self:getMonsters()
	else
		return self:getHeros()
	end	
end


function BattleBodyModel:getBodys()
	return self.bodys
end


function BattleBodyModel:getHeros()
	local result = {}
	for i = 1, 4 do
		if self.bodys and self.bodys["hero"..i] then
			result[tostring(i)] = self.bodys["hero"..i]
		end
	end
	return result
end


function BattleBodyModel:getMonsters()	
	local result = {}
	for i = 1, 4 do
		if self.bodys and self.bodys["monster"..i] then
			result[tostring(i)] = self.bodys["monster"..i]
		end
	end
	return result
end


function BattleBodyModel:getRandomAliveBodyId(withoutId)
	local heros = self:getHeros()
	local result = {}
	withoutId = withoutId or {}
	for i = 1, 4 do
		if heros[tostring(i)] and not heros[tostring(i)]:isDie() and withoutId ~= heros[tostring(i)]:get("id") then
			table.insert(result, heros[tostring(i)]:get("id"))
		end
	end

	if #result > 0 then
		return result[qy.DungeonUtil.random(#result)]
	else
		return nil
	end
end


function BattleBodyModel:getBodyByCampAtkPosition(campAtkPosition)
	local body = self.bodys[campAtkPosition]
	if body and type(body) == "string" then
		body = self.bodys[body]
	end
	print(campAtkPosition, body)
	assert(type(body) ~= "string", "body can not be string ")
	assert(body ~= nil			 , "body can not be nil")

	return body
end


function BattleBodyModel:getBodyByUniqueId(unique_id)
	for k, v in pairs(self.bodys) do
		if type(v) == "table" and tostring(v:get("id")) == tostring(unique_id) then
			return v
		end
	end
	return nil
end


--后端用的英雄数据格式
function BattleBodyModel:getServiceUseHeroData()
	local result = self:getHeros()
	for i = 1, 4 do
		if result[tostring(i)] then
			result[tostring(i)] = result[tostring(i)]:getServiceUseData()
		end
	end
	return result
end


--判断是否满足站位需求
function BattleBodyModel:judgementDemandPos(sender, demandPos)
	if demandPos and demandPos ~= "" then
		--我方站位需求不存在并且关系
		local demand_pos = qy.DungeonUtil.splitByStr(demandPos, "|")

		for i = 1, #demand_pos do
			local atkPosition = sender:get("atkPosition")
			if tostring(atkPosition) == demand_pos[i] then
				return true
			end
		end

		return false
	else
		return true
	end
end



--根据字符串获取释放对象 
--|为或，_为并且。 _为加法，不能做类似11_21,无法将它变成 阵位11并且要求11在攻击距离内，只能将它理解为攻击阵位11加一个非11的敌方攻击范围内
--1,2,3,4 我方1234 。 5我方随机 。
--11，12，13，14  15 同上
--21攻击距离范围内 
--99自身
--5，15随机一人，只给指挥技使用 
--除了1～4 11～14 其他不支持|和_

--目前的问题是当 1_5时。目的是英雄阵位1加英雄阵位随机一人，共2人，但当随机时如果随机到英雄阵位1，则不会添加到集合内，并且没有继续随机，所以会返回一个人

function BattleBodyModel:getBodyTarget(sender, targetData, result)
	if result == nil then
		result = {}
		result["type"] = "" --one选其一，all全部
		result["target"] = {}
	end


	if string.find(targetData, "|") == nil and string.find(targetData, "_") == nil then
		targetData = tonumber(targetData)

		-- 这段代码关系在于。 当目标填写 1～4 与 11～14 是定义为我方与敌方。还是定义为 英雄与怪物。   关闭这段代码就意味着 1～4永远是左方英雄，11～14永远代表右面怪物，与释放者阵营无关
		if sender and sender:get("camp") == "monster" then
			targetData = targetData < 10 and targetData + 10 or (targetData < 20 and targetData - 10 or targetData)
		end

		local bodys
		if targetData <= 10 then
			bodys = self:getHeros()
		else
			bodys = self:getMonsters()
		end

		if (targetData > 0 and targetData < 5) or (targetData > 10 and targetData < 15) then
			targetData = targetData > 10 and targetData - 10 or targetData
			local body = bodys[tostring(targetData)]
			if type(body) == "string" then
				body = self:getBodyByCampAtkPosition(body)
			end

			if body and not body:isDie() then
				local key = body:get("campAtkPosition")
				if result["target"][key] == nil then
					result["target"][key] = body
					result["type"] = "one"
				end
			end
		elseif targetData == 5 or targetData == 15 then
			local bodys2 = clone(bodys)
			for k, v in pairs(bodys2) do
				-- local body = type(v) == "string" and self:getBodyByCampAtkPosition(v) or v
				-- for k2, v2 in pairs(result["target"]) do
					if type(v) ~= "table" or result["target"][v:get("campAtkPosition")] ~= nil or v:isDie() then
						bodys2[k] = nil
					end
				-- end
			end

			local rad = qy.DungeonUtil.random(qy.DungeonUtil.getTableLength(bodys2))
			local i = 1
			for k, v in pairs(bodys2) do
				local key = v:get("campAtkPosition")
				if i == rad and result["target"][key] == nil then
					--这里注意要等于bodys[key] 而不是bodys2 因为bodys2是clone出来的，里面的entity的内存地址和bodys内的entity都不相同
					result["target"][key] = bodys[k]
					break
				end
				i = i + 1
			end
			bodys2 = nil
			result["type"] = "one"

		elseif targetData == 21 then
			local attackDistance = sender:getTotalProperty()["101"]
			local farthestAtkPos = attackDistance + 1 - tonumber(sender:get("atkPosition"))
			bodys = qy.BattleBodyModel:getOtherBodysByCamp(sender:get("camp"))

			for i = 1, farthestAtkPos do
				local body = type(bodys[tostring(i)]) == "string" and self:getBodyByCampAtkPosition(bodys[tostring(i)]) or bodys[tostring(i)]
				if body and result["target"][body:get("campAtkPosition")] == nil and not body:isDie() then
					result["target"][body:get("campAtkPosition")] = body
				end
			end

			result["type"] = "one"

		elseif targetData == 99 then
			local key = sender:get("campAtkPosition")
			if result["target"][key] == nil then
				result["target"][key] = sender
				result["type"] = "one"
			end
		end
	else

		targetData = qy.DungeonUtil.splitByStr(targetData, "|")

		for i = 1, #targetData do
			targetData[i] = qy.DungeonUtil.splitByStr(targetData[i], "_")
			--内循环是并且的关系
			for j = 1, #targetData[i] do
				result = self:getBodyTarget(sender, targetData[i][j], result)
			end

			result["type"] = "all"
		end

		--内层不管长度1或更多都可以是all，但外面只有长度大于1时才可以变one，而且|与_不可以同时出现
		if #targetData > 1 then
			result["type"] = "one"
		end

	end

	return result
end



--判断body是否可以行动
function BattleBodyModel:judgementBodyCanAct(body)
	--buff（眩晕buff，强制跳过buff）, 死亡。 无法行动，自动强制跳过
	if body:getTotalProperty("203") > 0 then
		return false
	end
	return true
end


--判断某个角色每个技能释放条件是否满足
--技能无法释放原因包括： 
-- 职业不符
-- 英雄所在位置不符
-- 冷却时间
-- 禁用
-- 攻击位置
-- 攻击距离有没有目标
-- 能量不足
function BattleBodyModel:judgementBodyAllSkill(body)
	local skillsData = body:get("skillsData")
	for k, data in pairs(skillsData) do

		if type(data) ~= "number" then
			skillsData[k]["status"] = ""
			local configData = qy.Config.skill[data["upgrade_id"]] or qy.Config.skill[data["skill_id"]]
			local bodyTotalProperty = body:getTotalProperty()

			if configData["type"] == 1 or configData["type"] == 6 then
				if self:judgementDemandPos(body, configData["demand_pos"]) then
					if body:getCDByKey("skill"..data["skill_id"]) == nil or body:getCDByKey("skill"..data["skill_id"]) == 0 then
						if not (bodyTotalProperty["202"] > 0 and configData["type"] == 1) and not (bodyTotalProperty["201"] > 0 and configData["type"] == 6) then
							local skillTarget = self:getBodyTarget(body, configData["target"])
							
							if qy.DungeonUtil.getTableLength(skillTarget["target"]) > 0 then
								skillsData[k]["target"] = skillTarget["target"]
								skillsData[k]["type"] 	= skillTarget["type"]

								if bodyTotalProperty["135"] >= configData["consume"] then
									if 	qy.SpecialSkillModel:getSpecialSkillData(configData["id"]) == nil 
										or qy.SpecialSkillModel:getSpecialSkillData(configData["id"]).judgement() then

									else
										skillsData[k]["status"] = "jinyong"
									end

								else							
									--能量不足
									skillsData[k]["status"] = "nenglingbuzhu"
								end
							else
								--释放对象为空
								skillsData[k]["status"] = "duixiang"
							end
						else
							--技能禁用
							skillsData[k]["status"] = "jinyong"
						end
					else
						--技能cd
						skillsData[k]["status"] = "cd"..body:getCDByKey("skill"..data["skill_id"])
					end
				else
					--站位不满足
					skillsData[k]["status"] = "zhanwei"
				end
			else
				--非主动技能
				skillsData[k]["status"] = "feizhudong"
			end
		end
	end

	body:set("skillsData", skillsData)
end


--更新body血量
function BattleBodyModel:updateBodyHp(body, updateNum)
	body:updateHP(updateNum)
end


function BattleBodyModel:judgementAllBodyJustDead(camp)
	local dieBody = {}
	local camps = {}
	
	if camp then
		camps[1] = camp
	else
		camps = {"hero", "monster"}
	end

	for j = 1, #camps do
		for i = 1, 4 do
			local body = self.bodys[camps[j]..i]

			if body and (type(body) == "table" and body:isDie()) and body.just_dead == true then
				body.just_dead = false
				dieBody[camps[j]..i] = 1
			end
		end

		--队友刚刚死亡
		if camps[j] == "hero" and qy.DungeonUtil.getTableLength(dieBody) > 0 then
	        qy.DungeonModel:triggerTalk(qy.BattleBodyModel:getRandomAliveBodyId(), 6)
		end 
	end


	return dieBody
end



--判断谁死了
function BattleBodyModel:judgementAllBodyDie()
	local dieBody = {}

	local camps = {"hero", "monster"}
	for j = 1, #camps do
		for i = 1, 4 do
			local body = self.bodys[camps[j]..i]

			if (type(body) == "table" and body:isDie()) or body == nil then
				dieBody[camps[j]..i] = 1
			end
		end
	end

	return dieBody
end


function BattleBodyModel:judgementGameLose()
	local num = 0
	if self.bodys then
		for i = 1, 4 do
			local body = self.bodys["hero"..i]
			if body == nil or type(body) == "string" or body:isDie() then
				num = num + 1
			end
		end	
	end

	if not self.bodys or num == 4 then
		--死光光，结算
		return "lose"
	end

	return ""
end


--判断战斗输赢
function BattleBodyModel:judgementBattleWin()
	local camps = {"hero", "monster"}
	for j = 1, #camps do
		local num = 0
		for i = 1, 4 do
			local body = self.bodys[camps[j]..i]
			if body == nil or type(body) == "string" or body:isDie() then
				num = num + 1
			end
		end

		if num == 4 and camps[j] == "hero" then
			--玩家死光，玩家输，结算
			return "lose"
		elseif num == 4 and camps[j] == "monster" then
			--怪物死光，玩家赢
			return "win"
		end
	end

	return ""
end


function BattleBodyModel:judgementCollapseAwakening()                  
	local result = {}
	local heros = self:getHeros()
    for i = 1, 4 do
        if heros[tostring(i)] and not heros[tostring(i)]:isDie() then
            local special = heros[tostring(i)]:get("special")
            if heros[tostring(i)]:getTotalProperty("113") >= 100 and special["done"] == 0 then
            	special["done"] = 1
            	heros[tostring(i)]:set("special", special)

            	local buff = qy.Config.buff[tostring(special["buff_id"]) or 0]

				for j = 1, 3 do
					if buff and buff["property_"..j] then
						heros[tostring(i)]:addBuff({
							["id"] 			= buff["id"], 
							["idx"] 		= tostring(j), 
							["skillType"] 	= "3"}, false)
					end
				end

            	table.insert(result, 
            		{["campAtkPosition"] = heros[tostring(i)]:get("campAtkPosition"), 
            		["status"] = tostring(special["type"]), 
            		["effect"] = heros[tostring(i)]:get("buffs")[buff["id"]]})
            end
        end
    end

    return result
end




--更新阵位信息，前面死了，后面的人往前移
function BattleBodyModel:updateAtkPosition()
	local camps = {"hero", "monster"}
	for i = 1, #camps do
		for j = 1, 4 do
			local body = self.bodys[camps[i]..j]
			if body == nil or (type(body) == "table" and body:isDie()) then
				-- body = nil
				-- self.bodys[camps[i]..j] = nil

				for k = j + 1, 4 do
					if type(self.bodys[camps[i]..k]) == "string" and self.bodys[camps[i]..k] == camps[i]..j then
						self.bodys[camps[i]..k] = nil

					elseif type(self.bodys[camps[i]..k]) == "table" and not self.bodys[camps[i]..k]:isDie() then
						self.bodys[camps[i]..j] = self.bodys[camps[i]..k]
						self.bodys[camps[i]..j]:set("campAtkPosition", camps[i]..j)
						self.bodys[camps[i]..j]:set("atkPosition", tostring(j))
						self.bodys[camps[i]..k] = body

						for l = 1, self.bodys[camps[i]..j]:get("body") - 1 do
							print(camps[i]..(j + l), camps[i]..j)
							self.bodys[camps[i]..(j + l)] = camps[i]..j
							self.bodys[camps[i]..(k + l)] = nil
						end

						break
					end
				end
			end
		end
	end

end


--添加所有人所有技能的前置cd
function BattleBodyModel:addAllBodysSkillFrontCD()	
	for k, body in pairs(self.bodys) do
		if type(body) == "table" then
			local skillsData = body:get("skillsData")
			for i = 1, 5 do			
				if type(skillsData[tostring(i)]) == "table" then
					local configData = qy.Config.skill[skillsData[tostring(i)]["upgrade_id"]] or qy.Config.skill[skillsData[tostring(i)]["skill_id"]]
					local frontCD = configData["front_cd"]
					body:addCD("skill"..configData["id"], frontCD)
				end
			end
		end
	end
end


--将所有被动技能 转换为buff
-- function BattleBodyModel:passiveSkill()	
-- 	for k, body in pairs(self.bodys) do
-- 		if type(body) == "table" then
-- 			local skillsData = body:get("skillsData")
-- 			for i = 1, 5 do
-- 				if type(skillsData[tostring(i)]) == "table" then
-- 					local skillConfigData = qy.Config.skill[skillsData[tostring(i)]["skill_id"]]

-- 					local buff = qy.Config.buff[tostring(skillConfigData["buff_id"]) or 0]

-- 					if skillConfigData["type"] == 3 and buff then
-- 						for j = 1, 3 do
-- 							--附加属性
-- 							local property = buff["property_"..j]

-- 							if property and property ~= "" then
-- 								self.bodys[k]:addBuff(
-- 									{["id"] 		= buff["id"], 
-- 									["idx"] 		= tostring(j), 
-- 									["duration"] 	= -1, 
-- 									["skillType"] 	= 3}, false)
-- 							end
-- 						end
-- 				    end
-- 				end
-- 			end
-- 		end
-- 	end
-- end


--指挥技能
function BattleBodyModel:commandSkill()
	local result = {}
	for k, body in pairs(self.bodys) do
		if type(body) == "table" and body:get("camp") == "hero" then
			local skillsData = body:get("skillsData")
			for i = 1, 5 do
				local data = {}
				if type(skillsData[tostring(i)]) == "table" then
					print(skillsData[tostring(i)]["upgrade_id"], skillsData[tostring(i)]["skill_id"])
					local configData = qy.Config.skill[skillsData[tostring(i)]["upgrade_id"]] or qy.Config.skill[skillsData[tostring(i)]["skill_id"]]

					if configData["type"] == 2 then
						local data = {}
						data["skillData"] = skillsData[tostring(i)]
						data["sender"] = body

						local target = self:getBodyTarget(body, configData["target"])
				        local targetData = qy.DungeonUtil.tableConvert(target["target"], function(a, b)
				            return tonumber(a:get("atkPosition")) < tonumber(b:get("atkPosition"))
				        end)

						if target["type"] == "all" then
						    data["target"] = targetData
						else
							local idx = qy.DungeonUtil.random(#targetData)
						    data["target"] = {[targetData[idx]:get("campAtkPosition")] = targetData[idx]}
						end
				        table.insert(result, qy.BattleModel:computingBattleResult(data))
				    end
				end
			end
		end
	end

	return result
end

--重置英雄的很多属性
function BattleBodyModel:resetBodys()
	for i = 1, 4 do
		if type(self.bodys["hero"..i]) == "table" then
			--能量
			self.bodys["hero"..i]:set("13501", math.min(10, 5 + self.bodys["hero"..i]:getTotalProperty("225")))
			--3次攻击暴击的回合数
			self.bodys["hero"..i]:set("218_num", 0)
		end
	end
end




function BattleBodyModel:clearData()
	self.bodys = {}
    self.speedQueue = {}
	self.endRound = {}
end



return BattleBodyModel