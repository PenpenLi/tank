local MaterialModel = qy.class("MaterialModel", qy.tank.model.BaseModel)

function MaterialModel:init(buildInfo)
	self.buildInfo = {}
	self.buildInfo =buildInfo
end

function MaterialModel:update(buildInfo)
	for k, v in pairs(buildInfo) do
		if self.buildInfo[k] then
			self.buildInfo[k] = v
		end		
	end
end

function MaterialModel:getBuileInfo(index)
	return self.buildInfo[index]
end

function MaterialModel:getCoinNum(id)
	return qy.Config.material_center[tostring(id)].expend1
end

function MaterialModel:getName(id)
	return qy.Config.material_center[tostring(id)].name
end

function MaterialModel:getDes(id)
	return qy.Config.material_center[tostring(id)].desc
end

function MaterialModel:getLevel(id)
	return qy.Config.material_center[tostring(id)].grade
end

function MaterialModel:getCanReceiveNum(id)
	return qy.Config.material_center[tostring(id)].buy_times
end

return MaterialModel