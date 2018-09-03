local PropModel = qy.class("PropModel", qy.tank.model.BaseModel)


function PropModel:init(prop)
	self.propData = {}
	for k, v in pairs(prop) do
        self.propData[k] = prop[k] or {}
        for k2, v2 in pairs(v) do
            local data 
            if v2 ~= -1 and v2["prop_id"] then
                data = clone(qy.Config.props[tostring(v2["prop_id"])])
                data["prop_id"] = v2["prop_id"]
                data["num"] = v2["num"]
            end
            self.propData[k][k2] = data
        end
    end
    self:sortPropsData()
end

function PropModel:getPropNumById(id)
    print('11111111111111',id)
    print("323232232323 ", qy.json.encode(self.propData))
    local propData = self.propData[tostring(id)]
    local num = 0
    if propData then
        for k, v in pairs(propData) do
            num = num + propData[k].num
        end
    else

    end
    
    return num
end

function PropModel:sortPropsData()
    self.propArray = nil
    self.propArray = {}
	for id, data in pairs(self.propData) do
        for key, value in pairs(data) do
            table.insert(self.propArray, value)
        end
    end
    table.sort(self.propArray, function(a, b)        
        if b["prop_id"] and not a["prop_id"] then
            return true
        elseif b["quality"] < a["quality"] then
            return true
        elseif a["equip_id"] and b["equip_id"] and b["quality"] == a["quality"] and b["type"] > a["type"] then
            return true
        elseif tonumber(b["id"]) > tonumber(a["id"]) and b["quality"] == a["quality"] and (not (a["equip_id"] and b["equip_id"]) or b["type"] > a["type"]) then
            return true
        else
            return false
        end
    end)  
end

function PropModel:updateProp(prop)
    for k, v in pairs(prop) do
        self.propData[k] = prop[k] or {}
        if self.propData[k] == -1 then
            self.propData = self:deletePropById(k)
        else
            for k2, v2 in pairs(v) do
                local data 
                if v2 ~= -1 and v2["prop_id"] then
                    data = clone(qy.Config.props[tostring(v2["prop_id"])])
                    data["prop_id"] = v2["prop_id"]
                    data["num"] = v2["num"]
                end
            self.propData[k][k2] = data
            end
        end
    end
    self:sortPropsData()
end

function PropModel:getPropData()
	return self.propArray
end

function PropModel:deletePropById(id)
    local tmp ={}
    for i in pairs(self.propData) do  
        table.insert(tmp,i)  
    end
    local newTbl = {}
    local i = 1
    while i <= #tmp do 
        local val = tmp [i]
        if val == id then
            table.remove(tmp,i) 
        else
            newTbl[val] = self.propData[val]
            i = i + 1  
        end  
    end 
    return newTbl
end

return PropModel