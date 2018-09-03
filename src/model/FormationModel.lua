local FormationModel = qy.class("FormationModel", qy.tank.model.BaseModel)

function FormationModel:init(formationInfo)
	self.formationInfo = {}
	self.formationInfo =formationInfo
	qy.Event.dispatch(qy.Event.UPDATE_FORMATION)
end

function FormationModel:getFormation()
	return self.formationInfo
end

function FormationModel:getFormationNum()
	local num = 0
	for k, v in pairs(self.formationInfo) do
		if v > 0 then
			num = num+1
		end
	end
	return num
end


return FormationModel