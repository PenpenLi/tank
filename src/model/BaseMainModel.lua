local BaseMainModel = qy.class("BaseMainModel", qy.tank.model.BaseModel)

function BaseMainModel:init(buildInfo)
	self.buildInfo = {}
	self.buildInfo =buildInfo
end

function BaseMainModel:update(buildInfo)
	for k, v in pairs(buildInfo) do
		if self.buildInfo[k] then
			self.buildInfo[k] = v
		end		
	end
end

function BaseMainModel:getBuileInfo(index)
	return self.buildInfo[index]
end

function BaseMainModel:getName(id)
	return qy.Config.main_base[tostring(id)].name
end

function BaseMainModel:getCoinNum(id)
	return qy.Config.main_base[tostring(id)].expend1
end

function BaseMainModel:getDes(id)
	return qy.Config.main_base[tostring(id)].desc
end

function BaseMainModel:getLevel(id)
	return qy.Config.main_base[tostring(id)].grade
end

function BaseMainModel:getCanReceiveNum(id)
	return qy.Config.main_base[tostring(id)].buy_times
end

function BaseMainModel:getMaxHeroNum()
	local id = self.buildInfo['15'].id
	local heroNum = qy.Config.main_base[tostring(id)].hero_num
	return heroNum
end

return BaseMainModel