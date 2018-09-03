local ArsenalModel = qy.class("ArsenalModel", qy.tank.model.BaseModel)

function ArsenalModel:init(buildInfo)
	self.buildInfo = {}
	self.buildInfo =buildInfo
end

function ArsenalModel:update(buildInfo)
	for k, v in pairs(buildInfo) do
		if self.buildInfo[k] then
			self.buildInfo[k] = v
		end		
	end
end

function ArsenalModel:getBuileInfo(index)
	return self.buildInfo[index]
end

function ArsenalModel:getRefreshNum(id)
	return qy.Config.armoury[tostring(id)].refresh_times
end

function ArsenalModel:getCoinNum(id)
	return qy.Config.armoury[tostring(id)].expend1
end

function ArsenalModel:getName(id)
	return qy.Config.armoury[tostring(id)].name
end

function ArsenalModel:getDes(id)
	return qy.Config.armoury[tostring(id)].desc
end

function ArsenalModel:getLevel(id)
	return qy.Config.armoury[tostring(id)].grade
end

function ArsenalModel:getCanReceiveNum(id)
	return qy.Config.armoury[tostring(id)].buy_times
end

return ArsenalModel