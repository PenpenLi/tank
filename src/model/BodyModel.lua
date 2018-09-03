local BodyModel = qy.class("BodyModel", qy.tank.model.BaseModel)


function BodyModel:init(hero)
	self.heros = {}
	for k, v in pairs(hero) do
		self:addHero(k, v)
	end
end


function BodyModel:getHeros()
	return self.heros
end

function BodyModel:getHeroNum()
	local num = 0
	for k, v in pairs(self.heros) do
		num = num +1
	end
	return num
end

function BodyModel:getHeroById(id)
	return self.heros[tostring(id)]
end

function BodyModel:deleteHeroById(id)
	local tmp ={}
	for i in pairs(self.heros) do  
		table.insert(tmp,i)  
	end
	local newTbl = {}
	local i = 1
	while i <= #tmp do 
		local val = tmp [i]
		if val == id then
			table.remove(tmp,i) 
		else
			newTbl[val] = self.heros[val]
			i = i + 1  
		end  
	end 
	return newTbl
end

function BodyModel:updateHero(hero)
	for k, v in pairs(hero) do
		if self.heros[tostring(k)] then
			if v== -1 then
				self.heros = self:deleteHeroById(k)
			else
				self.heros[tostring(k)]:update(v)
			end
		else
			self:addHero(k, v)
		end
	end
end

function BodyModel:addHero(unique_id, data)
	self.heros[tostring(unique_id)] = require("entity.HeroEntity").new(data)
end

return BodyModel