local AreaModel = qy.class("AreaModel", qy.tank.model.BaseModel)



------------------------------------------------------------------地图数据相关 start
function AreaModel:init(data)
	self.pass 		= data.pass
	self.boss_pass 	= data.boss_pass
	self.progress 	= data.progress
	self.area 		= data.area    
end


function AreaModel:updatePass(data)
    self.pass 		= data.pass
	self.boss_pass 	= data.boss_pass
	self.progress 	= data.progress
	self.area 		= data.area    
end


return AreaModel