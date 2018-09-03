local BattleModel = qy.class("BattleModel", qy.tank.model.BaseModel)

function BattleModel:init()
	if not self.listener then
	    self.listener = qy.Event.add(qy.Event.BATTLE_TARGET_SELECT, function(event)
	    	-- qy.BattleManager:showBattleAction(self:computingBattleResult(event._usedata))
			qy.BattleManager:update(self:computingBattleResult(event._usedata))
	    end)
	end
end

-- function BattleModel:setData(data)
-- 	-- self.sneakAttack = "1" --1敌方 2我方 0无偷袭
-- 	self.sneakAttack = data["sneakAttack"]
-- end

-- function BattleModel:getSneakObject() 
-- 	return self.sneakAttack
-- end


function BattleModel:getBattlePosByBody(body)
	return qy.BattleConfig.battlePos[body:get("direction").."_"..body:get("atkPosition")]
end


--计算伤害／治疗结果，buff添加结果
function BattleModel:computingBattleResult(data)
	local sender = data["sender"]
	local targets = data["target"]
	local skillData = data["skillData"]
	local skillConfigData = qy.Config.skill[skillData["upgrade_id"]] or qy.Config.skill[skillData["skill_id"]]

	local result = {}
	result["battActionType"] = skillConfigData["battle_action_type"]
	result["bodys"] = {}
	result["bodys"]["sender"] = {}
	result["bodys"]["sender"][1] = sender:get("campAtkPosition")
	result["bodys"]["target"] = {}
	result["skillId"] = skillConfigData["id"]
	result["hpUpdate"] = {}

	--附加buff
	local buff = qy.Config.buff[tostring(skillConfigData["buff_id"]) or 0]

	if buff then
		for j = 1, 3 do
			--添加时机
			local addTime = buff["add_time"..j]
			--攻击开始前
			if addTime == 1 and buff["propetry_target"..j] == "99" then
				self:buffJudgement({["idx"] = j, ["target"] = target, ["buff"] = buff, ["sender"] = sender, ["skillType"] = skillConfigData["type"]})
			end
		end
	end

	--效果类型，1伤害，2治疗，3其他
	local effectType = skillConfigData["effect_type"]
	--伤害系数
	local hurtRatio = skillConfigData["hurt_ratio"] or 0
	--伤害附加固定值
	local baseHurt = skillConfigData["base_hurt"] or 0
	--伤害段数
	local hurtFrequency = math.max(skillConfigData["hurt_frequency"] or 1, 1)
	--sender总属性
	local senderTotalProperty = sender:getTotalProperty()

	--将能量转化为攻击次数
	if type(senderTotalProperty["21901"]) == "number" and senderTotalProperty["21901"] > 0 then
		hurtFrequency = sender:get("13501")
		sender:set("13501", 1)
	end

	--更新技能cd
	sender:addCD("skill"..skillData["skill_id"], skillConfigData["post_cd"])
	--扣掉能量
	sender:addEnergy(-skillConfigData["consume"] or 0)

	for k, target in pairs(targets) do
		table.insert(result["bodys"]["target"], target:get("campAtkPosition"))
		result["hpUpdate"][target:get("campAtkPosition")] = {}

		if buff then
			for j = 1, 3 do				
				--添加时机
				local addTime = buff["add_time"..j]
				--攻击开始前

				if addTime == 1 and buff["propetry_target"..j] ~= "99" then
					self:buffJudgement({["idx"] = j, ["target"] = target, ["buff"] = buff, ["sender"] = sender, ["skillType"] = skillConfigData["type"]})
				end
			end
		end
		
		--target总属性
		local targetTotalProperty = target:getTotalProperty()

		local hpUpdate = 0

		--1伤害，2治疗，3其他
		if effectType == 1 then
			-- local senderAttack = qy.DungeonUtil.random(senderTotalProperty["104"] - senderTotalProperty["103"]) + senderTotalProperty["103"]
			local senderAttack = senderTotalProperty["102"]
			local hpUpdate1 = math.max(((senderAttack - targetTotalProperty["105"] * (1000 - senderTotalProperty["226"]) / 1000) * hurtRatio + baseHurt) * (1 + senderTotalProperty["131"] / 1000) * (1 - targetTotalProperty["132"] / 1000) ,
									((senderAttack * qy.Config.fight_coefficient["lowest"]["coeffcient"]) * hurtRatio + baseHurt) * (1 + senderTotalProperty["131"] / 1000) * (1 - targetTotalProperty["132"] / 1000))

			for i = 1, hurtFrequency do
				hpUpdate = hpUpdate1 / hurtFrequency

				--释放者的命中率
				local senderHitRate = senderTotalProperty["107"]
				--防守方的闪避率
				local targetDodgeRate = targetTotalProperty["108"]
				--伤害类型 normal正常 crit暴击
				local resultType = "normal"

				if qy.DungeonUtil.random(1000) <= senderHitRate - targetDodgeRate then
					--释放方暴击率
					local senderCritRate = senderTotalProperty["109"]
					--防守方抗暴击率
					local targetCritResistRate = senderTotalProperty["111"]

					if qy.DungeonUtil.random(1000) <= senderCritRate - targetCritResistRate then
						resultType = "crit"
						hpUpdate = hpUpdate * (2 + senderTotalProperty["11001"] / 1000) 
					end

					hpUpdate = math.floor(hpUpdate + 0.5)
					if hurtRatio > 0 then
						hpUpdate = -math.max(hpUpdate, 1)
					end
				else
					hpUpdate = "miss"
				end

				if buff and (hpUpdate ~= "miss" or skillData["type"] == 2) then
					for j = 1, 3 do
						local addTime = buff["add_time"..j]
						--生效对象
						local propetryTarget = buff["propetry_target"..j]
						--攻击后, 并且判断释放者不能连续给自己加同一个buff
						if addTime ~= "" and addTime ~= 1 and (i == 1 or propetryTarget ~= "99") then
							--为了在动画结束后显示buff效果，所以延迟0.9秒
							qy.DungeonUtil.asynExecute(function()
								self:buffJudgement({["idx"] = j, ["target"] = target, ["buff"] = buff, ["sender"] = sender, ["skillType"] = skillConfigData["type"]})
							end, qy.BattleConfig.battleAttackActionDuration)
						end
					end
				end

				if hpUpdate ~= "miss" then
					--对结果做最后的修正
					hpUpdate, resultType = self:reviseBattleResult(hpUpdate, sender, target, resultType)
				end

				qy.BattleBodyModel:updateBodyHp(target, hpUpdate)

				--人打怪 把怪打死
				if sender:get("camp") == "hero" and target:get("camp") == "monster" and target:isDie() then
					qy.DungeonUtil.asynExecute(function()
			        	qy.DungeonModel:triggerTalk(sender:get("id"), 9)
					end, qy.BattleConfig.battleAttackActionDuration)
				end

				--人物被击中, 被击中者崩溃状态，可能说话。  其他人崩溃状态，其他人可能说话
				if sender:get("camp") == "monster" and target:get("camp") == "hero" and hpUpdate ~= "miss" and hpUpdate < 0 then
			        if target:get("special")["type"] == 2 then
						qy.DungeonUtil.asynExecute(function()
					        qy.DungeonModel:triggerTalk(target:get("id"), 10, 20)
						end, qy.BattleConfig.battleAttackActionDuration)
				    else
				    	local heros = qy.BattleBodyModel:getHeros()
				    	local ids = {}
				    	for j = 1, 4 do
				    		if heros[tostring(j)] and heros[tostring(j)]:get("special")["type"] == 2 then
				    			table.insert(ids, heros[tostring(j)]:get("id"))
				    		end
				    	end
				    	if #ids > 0 then
							qy.DungeonUtil.asynExecute(function()
						    	qy.DungeonModel:triggerTalk(ids[qy.DungeonUtil.random(#ids)], 11, 10)
							end, qy.BattleConfig.battleAttackActionDuration)
					    end
				    end
				end
				
				table.insert(result["hpUpdate"][target:get("campAtkPosition")], {["num"] = hpUpdate, ["type"] = resultType})
			end
		--1伤害，2治疗，3其他
		elseif effectType == 2 then
			-- local senderAttack = qy.DungeonUtil.random(senderTotalProperty["104"] - senderTotalProperty["103"]) + senderTotalProperty["103"]
			if qy.SpecialSkillModel:getSpecialSkillData(skillConfigData["id"]) then

				qy.SpecialSkillModel:getSpecialSkillData(skillConfigData["id"]).excute(sender)
			else

				local senderAttack = senderTotalProperty["102"]
				hpUpdate = (senderAttack * hurtRatio + baseHurt) * (1 + targetTotalProperty["116"] / 1000)

				--释放方暴击率
				local senderCritRate = senderTotalProperty["109"]
				--伤害类型 normal正常 crit暴击
				local resultType = "normal"

				if qy.DungeonUtil.random(1000) <= senderCritRate then
					resultType = "crit"
					hpUpdate = hpUpdate * (2 + senderTotalProperty["11001"] / 1000)
				end

				hpUpdate = math.max(math.floor(hpUpdate + 0.5), 1)
				if buff then
					for j = 1, 3 do
						local addTime = buff["add_time"..j]
						--攻击后
						if addTime ~= 1 and addTime ~= "" then
							self:buffJudgement({["idx"] = j, ["target"] = target, ["buff"] = buff, ["sender"] = sender, ["skillType"] = skillConfigData["type"]})
						end
					end
				end

				--治疗系数为0 则不显示任何血量变化，也不计算修正相关，这样的技能一般只是单纯的buff或特殊技能
				if hurtRatio > 0 then

					--对结果做最后的修正
					hpUpdate, resultType = self:reviseBattleResult(hpUpdate, sender, target, resultType)

					qy.BattleBodyModel:updateBodyHp(target, hpUpdate)
					table.insert(result["hpUpdate"][target:get("campAtkPosition")], {["num"] = hpUpdate, ["type"] = resultType})
				end
			end
		end
	end
	print(qy.json.encode(result))
	return result
end



function BattleModel:buffJudgement(params)
	local idx = params["idx"]

	local buff = params["buff"]

	local sender = params["sender"]

	--技能释放对象，非buff对象
	local target = params["target"]
	--正负面buff 1正， 2负
	local positiveNegative = buff["Positive_negative"]
	--附加属性
	local property = buff["property_"..idx]

	function addBuff(body, buff, idx, skillType)
		local property = buff["property_"..idx]
		local flag = true
		--每种穿透都有百分百的基础值，所以都+1000
		if property == "20301" then
			flag = qy.DungeonUtil.random(1000) < math.min(math.max(sender:getTotalProperty("119") - body:getTotalProperty("120") + 1000, 0), 1000)
		elseif property == "20401" then
			flag = qy.DungeonUtil.random(1000) < math.min(math.max(sender:getTotalProperty("121") - body:getTotalProperty("122") + 1000, 0), 1000)
		elseif property == "20501" then
			flag = qy.DungeonUtil.random(1000) < math.min(math.max(sender:getTotalProperty("123") - body:getTotalProperty("124") + 1000, 0), 1000)
		end

		if flag == false then
			qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = body:get("campAtkPosition"), ["property"] = "resist", ["showName"] = false})
		else
			body:addBuff(
				{["id"] 		= buff["id"], 
				["idx"] 		= tostring(idx), 
				["skillType"] 	= skillType})
		end
	end


	if property and property ~= "" then
		--生效几率，千分比
		local effectProbability = buff["effect_probability"..idx]
		--生效对象
		local propetryTarget = buff["propetry_target"..idx]
		
		if qy.DungeonUtil.random(1000) <= effectProbability then
			local buffTarget
			if propetryTarget == "22" then
				buffTarget = target
			else
				buffTarget = qy.BattleBodyModel:getBodyTarget(sender, propetryTarget)
			end

			if buffTarget then
				if type(buffTarget["target"]) == "table" and qy.DungeonUtil.getTableLength(buffTarget["target"]) > 0 then
					for k, v in pairs(buffTarget["target"]) do
						addBuff(v, buff, idx, params["skillType"])
					end
				else
					addBuff(buffTarget, buff, idx, params["skillType"])
				end
			end
		end
	end
end



--修正最后的攻击结果
function BattleModel:reviseBattleResult(hpUpdate, sender, target, resultType)
	local senderTotalProperty = sender:getTotalProperty()
	local targetTotalProperty = target:getTotalProperty()
	local originalHpUpdate = hpUpdate
	print(1, hpUpdate)
	--每三次攻击必定触发暴击
	if senderTotalProperty["218"] > 0 then
		sender:set("218_num", (sender:get("218_num") or 0) + 1)
		if sender:get("218_num") >= 3 then
			if resultType == "normal" then
				hpUpdate = hpUpdate * (2 + senderTotalProperty["11001"] / 1000) 
				resultType = "crit"
			end
			sender:set("218_num", 0)
		end
	end
	print(2, hpUpdate)

	--标记额外伤害
	if (senderTotalProperty["20701"] > 0 or 
		senderTotalProperty["20702"] > 0) and 
		targetTotalProperty["20601"] > 0 and 
		hpUpdate < 0 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["20702"] / 1000)
	end

	print(3, hpUpdate)
	--对生命值大于80%的目标提高/降低伤害（公式外伤害）
	if senderTotalProperty["208"] ~= 0 and targetTotalProperty["134"] / targetTotalProperty["106"] >= 0.8 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["208"] / 1000)
	end

	print(4, hpUpdate)
	--对生命值小于25%的目标提高/降低伤害（公式外伤害）
	if senderTotalProperty["209"] ~= 0 and targetTotalProperty["134"] / targetTotalProperty["106"] <= 0.25 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["209"] / 1000)
	end
	print(5, hpUpdate)


	--吸血
	if senderTotalProperty["213"] > 0 and hpUpdate < 0 then
		local xixue = math.floor(0.5 + math.abs(hpUpdate * (senderTotalProperty["213"] / 1000)))
		
		qy.DungeonUtil.asynExecute(function()
			qy.BattleBodyModel:updateBodyHp(sender, math.abs(xixue))
			qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = sender:get("campAtkPosition"), ["effectValue"] = math.abs(xixue), ["property"] = "134", ["showName"] = false})
		end, qy.BattleConfig.battleAttackActionDuration)
	end

	print(6, hpUpdate)

	--暴击恢复能量
	if senderTotalProperty["214"] > 0 and resultType == "crit" then		
		qy.DungeonUtil.asynExecute(function()
			sender:set("13501", senderTotalProperty["214"] + senderTotalProperty["13501"])
			qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = sender:get("campAtkPosition"), ["property"] = "214", ["effectValue"] = senderTotalProperty["214"], ["showName"] = false})
		end, qy.BattleConfig.battleAttackActionDuration)
	end

	print(7, hpUpdate)


	--受到伤害恢复血量
	if targetTotalProperty["118"] > 0 and targetTotalProperty["134"] + hpUpdate > 0 then
		local huifu = math.floor(0.5 + targetTotalProperty["106"] * targetTotalProperty["118"] / 1000)
		
		qy.DungeonUtil.asynExecute(function()
			qy.BattleBodyModel:updateBodyHp(target, huifu)
			qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = target:get("campAtkPosition"), ["effectValue"] = huifu, ["property"] = "134", ["showName"] = false})
		end, qy.BattleConfig.battleAttackActionDuration)
	end

	print(8, hpUpdate)

	--对人类伤害加成
	if senderTotalProperty["126"] > 0 and targetTotalProperty["species"] == 1 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["126"] / 1000)
	end

	--对僵尸伤害加成
	if senderTotalProperty["128"] > 0 and targetTotalProperty["species"] == 2 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["128"] / 1000)
	end

	--对野兽伤害加成
	if senderTotalProperty["127"] > 0 and targetTotalProperty["species"] == 3 then

		hpUpdate = hpUpdate * (1 + senderTotalProperty["127"] / 1000)
	end

	print(9, hpUpdate)

	--伤害溢出
	if senderTotalProperty["21001"] > 0 and targetTotalProperty["134"] + hpUpdate < 0 then 
		local overflowHp = targetTotalProperty["134"] + hpUpdate
		local targets = {}
		for campAtkPosition, body in pairs(qy.BattleBodyModel:getBodys()) do
			if type(body) == "table" and body:get("camp") == target:get("camp") and campAtkPosition ~= target:get("campAtkPosition") and not body:isDie() then
				table.insert(targets, body)
			end
		end

		if #targets > 0 then
			for i = 1, #targets do
				local hpUpdate1 = math.floor(overflowHp / #targets * senderTotalProperty["21001"] / 1000 - 0.5)

				hpUpdate1 = hpUpdate1 * (1 + senderTotalProperty["131"] / 1000) * (1 - targets[i]:getTotalProperty()["132"] / 1000)
				local cloneSender = clone(sender)
				cloneSender:set("21001", -9999)
				hpUpdate1 = self:reviseBattleResult(hpUpdate1, cloneSender, targets[i])

				qy.DungeonUtil.asynExecute(function()
					qy.BattleBodyModel:updateBodyHp(targets[i], hpUpdate1)
					qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = targets[i]:get("campAtkPosition"), ["effectValue"] = hpUpdate1, ["property"] = "134", ["showName"] = false})
				end, qy.BattleConfig.battleAttackActionDuration)
			end 
		end
	end


	--人打怪暴击后加buff
	if sender:get("camp") == "hero" and target:get("camp") == "monster" and resultType == "crit" and senderTotalProperty["220"] > 0 then
        qy.DungeonUtil.asynExecute(function()
			local buff = qy.Config.buff[tostring(senderTotalProperty["220"]) or 0]
			if buff then
				for j = 1, 3 do
					if buff["property_"..j] then
						sender:addBuff(
							{["id"] 		= tostring(senderTotalProperty["220"]), 
							["idx"] 		= tostring(j), 
							["skillType"] 	= 3})
					end
				end
			end
		end, qy.BattleConfig.battleAttackActionDuration)
	end

	print(10, hpUpdate)

	--受到伤害，给自己加buff
	-- if sender:get("camp") == "monster" and target:get("camp") == "hero" and targetTotalProperty["222"] > 0 then
	if targetTotalProperty["222"] > 0 then
        qy.DungeonUtil.asynExecute(function()
			local buff = qy.Config.buff[tostring(targetTotalProperty["222"]) or 0]
			if buff then
				for j = 1, 3 do
					if buff["property_"..j] then
						target:addBuff(
							{["id"] 		= tostring(targetTotalProperty["222"]), 
							["idx"] 		= tostring(j), 
							["skillType"] 	= 3})
					end
				end
			end
		end, qy.BattleConfig.battleAttackActionDuration)
	end


	print(11, hpUpdate)

	--人打怪 造成额外伤害
	if sender:get("camp") == "hero" and target:get("camp") == "monster" and senderTotalProperty["221"] > 0 then
        qy.DungeonUtil.asynExecute(function()
			qy.BattleBodyModel:updateBodyHp(target, -math.floor(senderTotalProperty["102"] * senderTotalProperty["221"] / 1000))
			qy.Event.dispatch(qy.Event.BODY_INFO_SHOW_TEXT, {["campAtkPosition"] = target:get("campAtkPosition"), ["effectValue"] = -math.floor(senderTotalProperty["102"] * senderTotalProperty["221"] / 1000), ["property"] = "134", ["showName"] = false})
		end, qy.BattleConfig.battleAttackActionDuration)
	end


	print(12, hpUpdate)
	--怪打人暴击  人加5点压力
	if sender:get("camp") == "monster" and target:get("camp") == "hero" and resultType == "crit" then
		qy.DungeonUtil.asynExecute(function()
			target:addBuff({
				["property"] 	= "11301",
				["effectValue"] = 5,
			})

			--人物被暴击
			qy.DungeonUtil.asynExecute(function()
				qy.DungeonModel:triggerTalk(target:get("id"), 7)
			end, qy.BattleConfig.battleAttackActionDuration)
		end, qy.BattleConfig.battleAttackActionDuration)
	end
	print(13, hpUpdate)

	--人打怪暴击  人物概率说话
	if sender:get("camp") == "hero" and target:get("camp") == "monster" and resultType == "crit" then
		qy.DungeonUtil.asynExecute(function()
			qy.DungeonModel:triggerTalk(sender:get("id"), 8, 20)
		end, qy.BattleConfig.battleAttackActionDuration)
	end

	print(14, hpUpdate)
	------------------------------最后修正
	print(senderTotalProperty["104"], senderTotalProperty["103"])
	local random = qy.DungeonUtil.random(senderTotalProperty["104"] - senderTotalProperty["103"]) + senderTotalProperty["103"]
	hpUpdate = random / 1000 * hpUpdate
	print(15, hpUpdate, math.floor(hpUpdate))

	return math.floor(hpUpdate), resultType
end





--自动战斗逻辑
function BattleModel:autoBattle(sender)
	local skillsData = sender:get("skillsData")

	local skillArray = {}
	skillArray["cure"] = {}
	skillArray["attack"] = {}

	for k, data in pairs(skillsData) do
		if type(data) == "table" then
			local skillConfigData = qy.Config.skill[data["upgrade_id"]] or qy.Config.skill[data["skill_id"]]
			if data["status"] == "" and (skillConfigData["type"] == 1 or skillConfigData["type"] == 6) then

				if skillConfigData["effect_type"] == 1 then
					table.insert(skillArray["attack"], k)
				elseif skillConfigData["effect_type"] == 2 then
					table.insert(skillArray["cure"], k)
				end
			end
		end
	end


	local skillArray2 = {}
	skillArray2["cure1"] = {}
	skillArray2["cure2"] = {}
	skillArray2["attack"] = skillArray["attack"]

	for i = 1, #skillArray["cure"] do
		local targets = skillsData[skillArray["cure"][i]]["target"]

		for campAtkPosition, target in pairs(targets) do
			local targetTotalProperty = target:getTotalProperty()
			local hp = targetTotalProperty["134"]
			local maxHp = targetTotalProperty["106"]

			if hp / maxHp < 0.7 then
				table.insert(skillArray2["cure1"], skillArray["cure"][i])
				break
			elseif hp / maxHp < 0.9 then
				table.insert(skillArray2["cure2"], skillArray["cure"][i])
				break
			end
		end
	end
	

	local skill
	if #skillArray2["cure1"] > 0 then
		skill = skillArray2["cure1"][qy.DungeonUtil.random(#skillArray2["cure1"])]
	elseif #skillArray2["cure2"] > 0 and #skillArray2["attack"] > 0 then
		if qy.DungeonUtil.random(100) > 50 then 
			skill = skillArray2["cure2"][qy.DungeonUtil.random(#skillArray2["cure2"])]
		else
			skill = skillArray2["attack"][qy.DungeonUtil.random(#skillArray2["attack"])]
		end
	elseif #skillArray2["cure2"] > 0 then
		skill = skillArray2["cure2"][qy.DungeonUtil.random(#skillArray2["cure2"])]
	elseif #skillArray2["attack"] > 0 then
		local idx = qy.DungeonUtil.random(#skillArray2["attack"])
		skill = skillArray2["attack"][idx]
	-- else
	-- 	--跳过
	end

	if skill then
		local data = {}
		data["skillData"] = skillsData[skill]
		data["sender"] = sender

		local target = skillsData[skill]["target"]
		local _type = skillsData[skill]["type"]
        local targetData = qy.DungeonUtil.tableConvert(target, function(a, b)
            return tonumber(a:get("atkPosition")) < tonumber(b:get("atkPosition"))
        end)

		if _type == "all" then
		    data["target"] = targetData
		else
			local idx = 1
			local configData = qy.Config.skill[data["skillData"]["upgrade_id"]] or qy.Config.skill[data["skillData"]["skill_id"]]
			if configData["effect_type"] == 2 then
				local minHp = 1
				for i = 1, #targetData do
					if targetData[i]:getTotalProperty()["134"] / targetData[i]:getTotalProperty()["106"] < minHp then
						minHp = targetData[i]:getTotalProperty()["134"] / targetData[i]:getTotalProperty()["106"]
						idx = i
					end
				end
			else
				idx = qy.DungeonUtil.random(#targetData)
			end

			data["target"] = {[targetData[idx]:get("campAtkPosition")] = targetData[idx]}
		end

		-- qy.BattleManager:showBattleAction(self:computingBattleResult(data))
		qy.BattleManager:update(self:computingBattleResult(data))
	else
		--跳过
		qy.BattleManager:skipCurrentBody()
	end
end






return BattleModel