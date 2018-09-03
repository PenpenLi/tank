local GuideModel = qy.class("GuideModel", qy.tank.model.BaseModel)

function GuideModel:init(guideData)
	--self.guideIndex = 0
	self.isOpenGuide = true
	self.guideIndex = guideData.current_step_id
end

function GuideModel:getIsGuide()
	return self.isOpenGuide
end

function GuideModel:getGuideIndex()
	 return self.guideIndex
end

function GuideModel:setGuideIndex(index)
	 self.guideIndex = index
end

return GuideModel