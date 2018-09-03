local TrainingModel = qy.class("TrainingModel", qy.tank.model.BaseModel)

function TrainingModel:init(buildInfo)
	self.buildInfo = {}
	self.buildInfo =buildInfo
end

function TrainingModel:update(buildInfo)
	for k, v in pairs(buildInfo) do
		if self.buildInfo[k] then
			self.buildInfo[k] = v
		end		
	end
end

function TrainingModel:getBuileInfo(index)
	return self.buildInfo[index]
end

function TrainingModel:getRefreshNum(id)
	return qy.Config.training_ground[tostring(id)].refresh_times
end

function TrainingModel:getCoinNum(id)
	return qy.Config.training_ground[tostring(id)].expend1
end

function TrainingModel:getName(id)
	return qy.Config.training_ground[tostring(id)].name
end

function TrainingModel:getDes(id)
	return qy.Config.training_ground[tostring(id)].desc
end

function TrainingModel:getLevel(id)
	return qy.Config.training_ground[tostring(id)].grade
end

function TrainingModel:getCanReceiveNum(id)
	return qy.Config.training_ground[tostring(id)].buy_times
end

return TrainingModel