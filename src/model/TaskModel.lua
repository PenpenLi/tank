local TaskModel = qy.class("TaskModel", qy.tank.model.BaseModel)

function TaskModel:init(buildInfo)
	self.taskInfo = {}
	self.taskInfo =buildInfo
end

function TaskModel:update(taskInfo)
	for k, v in pairs(taskInfo) do
		if self.taskInfo[k] then
			self.taskInfo[k] = v
		end		
	end
end

function TaskModel:getAllMail()
	local tastArray = {}
	for k, v in pairs(self.taskInfo.daily) do
		table.insert(tastArray,v)
	end
	for k, v in pairs(self.taskInfo.current_task) do
		table.insert(tastArray,v)
	end
	return tastArray
end

function TaskModel:getDailyInfo()
	local tastArray = {}
	for k, v in pairs(self.taskInfo.daily) do
		if v.finish and v.finish ~= -1 then
			table.insert(tastArray,v)
		end
	end
	table.sort(tastArray, function(a, b)
		  local r
		  local al = tonumber(a.id)
		  local bl = tonumber(b.id)
		  r = bl > al
		  return r
	end)
	return tastArray
end

function TaskModel:getMainInfo()
	local tastArray = {}
	for k, v in pairs(self.taskInfo.current_task) do

		table.insert(tastArray,v)
	end
	return tastArray
end

function TaskModel:getLongDes(id)
	return qy.Config.task[tostring(id)].desc2
end

function TaskModel:getSmallDes(id)
	return qy.Config.task[tostring(id)].desc
end

function TaskModel:getAward(id)
	return qy.Config.task[tostring(id)].reward
end

function TaskModel:getTaskAllNum(id)
	return qy.Config.task[tostring(id)].condition
end

return TaskModel