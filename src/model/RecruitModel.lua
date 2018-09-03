local RecruitModel = qy.class("RecruitModel", qy.tank.model.BaseModel)

function RecruitModel:init(data)
	self:setRecruit1(data.recruit1)
	self:setRecruit2(data.recruit2)
	self:setRecruit3(data.recruit3)
	if data.await then
		self:setAwait(data.await)
	end
end

function RecruitModel:setRecruit1(data)
	self.recruit1 = data
end

function RecruitModel:setRecruit2(data)
	self.recruit2 = data
end

function RecruitModel:setRecruit3(data)
	self.recruit3 = data
end

function RecruitModel:setAwait(data)
	self.await = data
end

function RecruitModel:getRecruit3()
	return self.recruit3
end

function RecruitModel:getAwait()
	return self.await
end

function RecruitModel:getCostPriceByType(type)
	local price = 0
	if type == 3 then
		price = "X"..qy.Config.recruit['3'].cost..'刷新'
	end
	if type == 2 then
		price = "X"..(qy.Config.recruit['2'].cost * 5 * (self.recruit2.refresh_today_count+1))..'刷新'
	end
	return price
end

function RecruitModel:getZhieyeNameByIndex(type)
	local text = ""
	if type == 1 then
		text = qy.TextUtil:substitute('defender')
	end
	if type == 2 then
		text = qy.TextUtil:substitute('enlistee')
	end
	if type == 3 then
		text = qy.TextUtil:substitute('explorer')
	end
	if type == 4 then
		text = qy.TextUtil:substitute('therapist')
	end
	if type == 5 then
		text = qy.TextUtil:substitute('adventurer')
	end
	return text
end


return RecruitModel