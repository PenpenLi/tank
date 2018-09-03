local EquipModel = qy.class("EquipModel", qy.tank.model.BaseModel)


function EquipModel:init(equip)
	self.equipOBject = {}
	self.equipArray = {}
	
	for k, v in pairs(equip) do
		self.equipOBject[k] = require("entity.EquipEntity").new(v)
	end

	for k, v in pairs(equip) do
		table.insert(self.equipArray,require("entity.EquipEntity").new(v))
	end
end

function EquipModel:updateEquipById(equip)
	for k, v in pairs(equip) do
		if self.equipOBject[k] then
			if v == -1 then
				--table.remove(self.equipOBject, k)
				self.equipOBject = self:deleteEquipById(k)
			else
				self.equipOBject[k]:update(v)
			end
			
		else
			self:addEquip(k, v)
		end		
	end
end

function EquipModel:addEquip(unique_id, data)
	self.equipOBject[tostring(unique_id)] = require("entity.EquipEntity").new(data)
end

function EquipModel:getEquipById(id)
	return self.equipOBject[tostring(id)]
end

function EquipModel:getEquipDataByType(type,isInHome)
	local equipArray = {}

	if isInHome then
		for k, v in pairs(self.equipOBject) do
			if self.equipOBject[k].type == type and self.equipOBject[k].heroOnId == 0 then
				table.insert(equipArray,self.equipOBject[k])
			end
		end
	else
		local allEquip = qy.DungeonModel:getBackpackEquipData()--探索中装备仓库
		for i= 1, #allEquip do
			local unique_id = tostring(allEquip[i].unique_id)
      		if self.equipOBject[unique_id].type == type and self.equipOBject[unique_id].heroOnId == 0 then
				table.insert(equipArray,self.equipOBject[unique_id])
			end
    	end
	end

	table.sort(equipArray, function(a, b)
		  local r
		  --local al = tonumber(a.strengthen_level)
		  --local bl = tonumber(b.strengthen_level)
		  local aq = tonumber(a.quality)
		  local bq = tonumber(b.quality)
		  local aid = tonumber(a.rank)
		  local bid = tonumber(b.rank)
		  if aq == bq then
		      r = aid > bid
		    else
		      r = aq > bq
		    end 
		  return r
	end)

	return equipArray;

	
end

function EquipModel:getEquipName(type)
	local text = ""
	if type == 1 then
		text = qy.TextUtil:substitute('weapon')
		return text
	end
	if type == 2 then
		text = qy.TextUtil:substitute('helmet')
		return text
	end
	if type == 3 then
		text = qy.TextUtil:substitute('clothes')
		return text
	end
	if type == 4 then
		text = qy.TextUtil:substitute('shoes')
		return text
	end
	if type == 5 then
		text = qy.TextUtil:substitute('accessory')
		return text
	end
	if type == 6 then
		text = qy.TextUtil:substitute('accessory')
		return text
	end
end

function EquipModel:getColorByQuality(quality)
	if quality == 2 then
		local color = cc.c3b(18, 255, 0)
		return color
	end
	if quality == 3 then
		local color = cc.c3b(0, 198, 255)
		return color
	end
	if quality == 4 then
		local color = cc.c3b(216, 0, 255)
		return color
	end
	if quality == 5 then
		local color = cc.c3b(255, 144, 0)
		return color
	end
	if quality == 6 then
		local color = cc.c3b(208, 183, 124)
		return color
	end
	if quality == 1 then
		local color = cc.c3b(252, 253, 228)
		return color
	end
	if quality == 0 then
		local color = cc.c3b(252, 253, 228)
		return color
	end
end

function EquipModel:getAllEquip()
	local equipArray = {}
	for k, v in pairs(self.equipOBject) do
		if(self.equipOBject[k].heroOnId == 0) then
			table.insert(equipArray,self.equipOBject[k])
		end
	end

	table.sort(equipArray, function(a, b)
		  local r
		  --local al = tonumber(a.strengthen_level)
		  --local bl = tonumber(b.strengthen_level)
		  local aq = tonumber(a.quality)
		  local bq = tonumber(b.quality)
		  local aid = tonumber(a.rank)
		  local bid = tonumber(b.rank)
		  local typea = tonumber(a.type)
		  local typeb = tonumber(b.type)
		  if typea == typeb then
			 if aq == bq then
			      r = aid > bid
			    else
			      r = aq > bq
			    end 
		  else
		  	r = typea < typeb
		  end
		  return r
	end)

	return equipArray;
end

function EquipModel:deleteEquipById(id)
	local tmp ={}
	for i in pairs(self.equipOBject) do  
		table.insert(tmp,i)  
	end
	local newTbl = {}
	local i = 1
	while i <= #tmp do 
		local val = tmp [i]
		if val == id then
			table.remove(tmp,i) 
		else
			newTbl[val] = self.equipOBject[val]
			i = i + 1  
		end  
	end 
	return newTbl
end

function EquipModel:getEquipBattle(zhudongData,fujiaData,level,isHaveSkill)
	local battle = 0

	for i= 1, #zhudongData do
        local value = zhudongData[i].effectValue
        local attrId = zhudongData[i].propertyId
        local text = qy.TextUtil:substitute("property_"..attrId)
        if text == "" then
            local num1 = math.floor(attrId/100)
            local num2 = attrId%100
            local qianfenbi = qy.Config.property[tostring(num1)].property_permillage
            if qianfenbi == 0 then
                if num2 == 1 then
                    value = value
                elseif num2 == 2 then
                    value = (value/1000)
                end
            elseif qianfenbi == 1 then
                value = (value/1000)
            elseif qianfenbi == 2 then
                 value = (value/1000)
            end
        end
        battle = battle + self:calcBattleValue(attrId,value,level)
    end

    for i= 1, #fujiaData do
        local value = fujiaData[i].effectValue
        local attrId = fujiaData[i].propertyId
        local text = qy.TextUtil:substitute("property_"..attrId)
        if text == "" then
            local num1 = math.floor(attrId/100)
            local num2 = attrId%100
            local qianfenbi = qy.Config.property[tostring(num1)].property_permillage
            if qianfenbi == 0 then
                if num2 == 1 then
                    value = value
                elseif num2 == 2 then
                    value = (value/1000)
                end
            elseif qianfenbi == 1 then
                value = (value/1000)
            elseif qianfenbi == 2 then
                 value = (value/1000)
            end
        end
        battle = battle + self:calcBattleValue(attrId,value,level)
    end

    if isHaveSkill then
    	local allGongji = 113.9 + (level - 1) * 28.5
    	battle = battle + (0.02 * allGongji / 2 * 0.5 * 40)
    end
	return battle
end

function EquipModel:calcBattleValue(attrId,value,level)
	local battle = 0
	if attrId == 10201 then
		battle = value * 18
	elseif attrId == 10501 then
		battle = value * 36
	elseif attrId == 10601 then
		battle = value * 10
	elseif attrId == 13201 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji / 2 * 40
	elseif attrId == 13101 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji / 2 * 40
	elseif attrId == 10901 then
		battle = value * 7
	elseif attrId == 11101 then
		battle = value * 7
	elseif attrId == 10801 then
		battle = value * 7.2
	elseif attrId == 10701 then
		battle = value * 7.2
	elseif attrId == 12601 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 12701 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 12801 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 13601 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 13701 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 13801 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value / 3 * allGongji / 2 * 40
	elseif attrId == 13001 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji / 2 * 1.4 * 0.5 * 40
	elseif attrId == 12901 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji / 2 * 1 * 0.5 * 40
	elseif attrId == 11601 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji * 0.5 * 10
	elseif attrId == 11501 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = (value/2/100) * (allGongji*18/2*0.15+allGongji*18*0.05/2/2)
	elseif attrId == 11401 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = (value/2/100) * (allGongji*18/2*0.15+allGongji*18*0.05/2/2)
	elseif attrId == 13301 then
		local allGongji = 113.9 + (level - 1) * 28.5
		local allSpeed = 54.8 + (level - 1) * 9.5
		battle = value / allSpeed * allGongji * 18 / 4
	elseif attrId == 11001 then
		local allGongji = 113.9 + (level - 1) * 28.5
		local allBaoji = 0.22
		battle = value * (allGongji * allBaoji / 2 * 0.9) * 40
	elseif attrId == 11903 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 12303 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 12103 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 12003 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 12403 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 12203 then
		local allGongji = 113.9 + (level - 1) * 28.5
		battle = value * allGongji /4 * 18 * 2
	elseif attrId == 10101 then
		local allGongji = 113.9 + (level - 1) * 28.5
		if value < 4 then
			battle = allGongji /4 * 18 * 0.5 * (value - 1) / 4
		elseif  value == 4 then
			battle = allGongji /4 * 18 * 0.5 * 3.75 / 4
		elseif  value == 5 then
			battle = allGongji /4 * 18 * 0.5 * 4.25 / 4
		elseif  value > 5 then
			battle = allGongji /4 * 18 * 0.5 * 4.5 / 4
		end
	end
	print('11111111111111',battle)
	return battle
end

function EquipModel:getAttrChange(id, value,equipData)
	local array = {["isShow"] = false,["isUp"] = 1}--0表示下降，1不变 2 上升
	for i= 1, #equipData do
		if equipData[i].propertyId == id then
			array['isShow'] = true
			--print('ttttttttttttt',id,value)
			if id == '103_104' then
				local target1 = string.split(value, "-")
				local target11 = string.split(target1[1], "%")
				local target12 = string.split(target1[2], "%")
				target11 = target11[1]
				target12 = target12[1]
				local target2 = string.split(equipData[i].effectValue, "-")
				local target21 = string.split(target2[1], "%")
				local target22 = string.split(target2[2], "%")
				target21 = target21[1]
				target22 = target22[1]
				local number1 = tonumber(target11) + tonumber(target12)
				local number2 = tonumber(target21) + tonumber(target22)
				if number2 > number1 then
					array['isUp'] = 0
				elseif number2 == number1 then
					array['isUp'] = 1
				elseif number2 < number1 then
					array['isUp'] = 2
				end
			else
				if equipData[i].effectValue > value then
					array['isUp'] = 0
				elseif equipData[i].effectValue == value then
					array['isUp'] = 1
				elseif equipData[i].effectValue < value then
					array['isUp'] = 2
				end
			end
			
			return array
		end
	end
	return array
end

return EquipModel